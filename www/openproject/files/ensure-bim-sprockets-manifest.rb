#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#
# Merge BIM login-logo logical paths into a packaged .sprockets-manifest-*
# when the PNGs are present. Core app/views/custom_styles/_inline_css_logo.erb
# calls asset_path("bim/logo_openproject_bim_big_coloured.png") on every
# /login even when openproject-bim is not bundled (day-one: no BIM IFC).
# assets:precompile then omits those keys; /login 500s until they exist.

require "digest"
require "fileutils"
require "json"
require "time"

LOGICAL_PATHS = %w[
  bim/logo_openproject_bim_big.png
  bim/logo_openproject_bim_big_coloured.png
].freeze

def manifest_paths(public_assets)
  Dir.glob(File.join(public_assets, ".sprockets-manifest-*.json")).sort +
    Dir.glob(File.join(public_assets, "manifest-*.json")).sort
end

def source_for(root, logical)
  base = File.basename(logical)
  [
    File.join(root, "app", "assets", "images", "bim", base),
    File.join(root, "modules", "bim", "app", "assets", "images", "bim", base)
  ].find { |path| File.file?(path) }
end

def existing_packaged(public_assets, logical)
  exact = File.join(public_assets, logical)
  return logical if File.file?(exact)

  base = File.basename(logical, ".*")
  ext = File.extname(logical)
  dir = File.join(public_assets, File.dirname(logical))
  return nil unless File.directory?(dir)

  # Sprockets: name-<hexdigest>.ext ; webpack: name.<hash>.ext
  Dir.children(dir).sort.each do |name|
    next unless name.start_with?(base) && name.end_with?(ext)
    rest = name[base.length...-ext.length]
    next unless rest.start_with?("-") || rest.start_with?(".")
    return File.join(File.dirname(logical), name)
  end
  nil
end

def ensure_packaged_file(root, public_assets, logical)
  packaged = existing_packaged(public_assets, logical)
  return packaged if packaged

  src = source_for(root, logical)
  return nil unless src

  dest = File.join(public_assets, logical)
  FileUtils.mkdir_p(File.dirname(dest))
  FileUtils.cp(src, dest)
  logical
end

def file_entry(public_assets, packaged, logical)
  full = File.join(public_assets, packaged)
  digest = Digest::SHA256.file(full).hexdigest
  {
    "logical_path" => logical,
    "mtime" => File.mtime(full).utc.xmlschema,
    "size" => File.size(full),
    "digest" => digest
  }
end

def merge_manifest(root, public_assets, path)
  data = JSON.parse(File.read(path))
  assets = data["assets"] ||= {}
  files = data["files"] ||= {}
  changed = false

  LOGICAL_PATHS.each do |logical|
    packaged = ensure_packaged_file(root, public_assets, logical)
    next if packaged.nil?
    next if assets[logical] == packaged && files.key?(packaged)

    assets[logical] = packaged
    files[packaged] ||= file_entry(public_assets, packaged, logical)
    changed = true
  end

  File.write(path, JSON.generate(data)) if changed
  changed
end

def ensure_manifests(root)
  public_assets = File.join(root, "public", "assets")
  unless File.directory?(public_assets)
    warn "ensure-bim-sprockets-manifest: no public/assets under #{root}"
    return 0
  end

  manifests = manifest_paths(public_assets)
  if manifests.empty?
    # Files may already be under public/assets/bim with no manifest yet.
    LOGICAL_PATHS.each { |logical| ensure_packaged_file(root, public_assets, logical) }
    warn "ensure-bim-sprockets-manifest: no .sprockets-manifest-* under #{public_assets}"
    return 0
  end

  manifests.count { |path| merge_manifest(root, public_assets, path) }
end

def self_test
  require "tmpdir"
  Dir.mktmpdir("op-bim-manifest-") do |tmp|
    public_assets = File.join(tmp, "public", "assets")
    bim_pub = File.join(public_assets, "bim")
    src = File.join(tmp, "modules", "bim", "app", "assets", "images", "bim")
    FileUtils.mkdir_p(bim_pub)
    FileUtils.mkdir_p(src)

    coloured = "logo_openproject_bim_big_coloured.png"
    plain = "logo_openproject_bim_big.png"
    File.write(File.join(bim_pub, coloured), "COLOURED")
    File.write(File.join(src, plain), "PLAIN")

    manifest = File.join(public_assets, ".sprockets-manifest-test.json")
    File.write(manifest, JSON.generate({
      "assets" => { "application.js" => "application-aaa.js" },
      "files" => {
        "application-aaa.js" => { "logical_path" => "application.js", "size" => 1 }
      }
    }))

    raise "expected merge" unless ensure_manifests(tmp) == 1

    data = JSON.parse(File.read(manifest))
    unless data["assets"]["bim/#{coloured}"] == "bim/#{coloured}"
      raise "coloured logical path not mapped"
    end
    unless data["assets"]["bim/#{plain}"] == "bim/#{plain}"
      raise "plain logical path not mapped after copy from modules/bim"
    end
    unless File.file?(File.join(bim_pub, plain))
      raise "plain logo was not copied into public/assets/bim"
    end
    unless data.dig("files", "bim/#{coloured}", "logical_path") == "bim/#{coloured}"
      raise "files[] entry missing"
    end

    # Idempotent when keys already match shipped files.
    raise "second pass should be a no-op" unless ensure_manifests(tmp) == 0

    # Digested filename already on disk, logical key missing.
    digested = "logo_openproject_bim_big-abc123def456.png"
    File.write(File.join(bim_pub, digested), "DIGESTED")
    data["assets"].delete("bim/#{plain}")
    File.delete(File.join(bim_pub, plain))
    File.write(manifest, JSON.generate(data))
    raise "expected digested merge" unless ensure_manifests(tmp) == 1
    data = JSON.parse(File.read(manifest))
    unless data["assets"]["bim/#{plain}"] == "bim/#{digested}"
      raise "did not map logical path to digested packaged file"
    end
  end
  puts "ensure-bim-sprockets-manifest: self-test ok"
end

if ARGV[0] == "--self-test"
  self_test
else
  root = ARGV[0] || Dir.pwd
  ensure_manifests(root)
end
