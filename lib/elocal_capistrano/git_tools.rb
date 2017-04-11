require 'yaml'

module ElocalCapistrano::GitTools
  # Represents an API release, which is tagged in the repository as
  # +rel_<MAJOR>.<MINOR>.<PATCH>+. Capistrano uses this pushed tag
  # to deploy the next version of the API, which is reflected in the
  # footer of each page. In development mode, this simply returns the
  # latest commit in master.
  class ReleaseTag
    attr_accessor :major, :minor, :patch, :other

    # Create a new ReleaseTag from a version string.
    def initialize(tag=nil)
      @major, @minor, @patch, @other = tag.gsub(/^rel_/,'').split(/[^0-9a-zA-Z]+/).map(&:to_i) unless tag.nil?
    end

    # Version number as an array of integers.
    def to_a
      [@major, @minor, @patch, @other].compact
    end

    # Compare two tags by version. The latest version is always chosen.
    def <=>(rel_tag)
      to_a <=> rel_tag.to_a
    end

    # Version number as a string, or tag name.
    def to_s
      "rel_" + to_a.compact.join(".")
    end

    def ==(rel_tag)
      to_a == rel_tag.to_a
    end

    # Return the current ReleaseTag as specified in versions.yml.
    def self.current(environment="production")
      ReleaseTag.new(versions_hash[environment])
    end

    # Return the latest ReleaseTag as computed by looking at the most
    # recent "rel_*" tag created on Git.
    def self.latest
      tags = %x(git tag).split("\n").select{|l| l =~ /^rel_/}.map{ |l| ReleaseTag.new(l) }.sort
      tags.last || ReleaseTag.new('rel_0.0.0')
    end
  end

  # A short user prompt if there are uncommitted changes in the repo, in
  # case the user forgets before they deploy. Naturally, one may cancel
  # this process effectively cancelling the entire deploy cleanly. This
  # occurs before any hard changes (e.g., writing changes, pushes,
  # command execution, etc.) are made.
  def working_directory_copasetic?(options={})
    return true if options[:force]
    return false unless no_changes_pending? || yes?('There are currently uncommitted changes.  Are you sure you want to continue?')
    return false unless on_master? || yes?('You are not currently on the master branch.  Are you sure you want to continue?')
    true
  end

  # Test whether we are currently using the master branch. All
  # deployment activity should take place on the master branch.
  def on_master?
    out = %x(git symbolic-ref -q HEAD)
    out.strip == "refs/heads/master"
  end

  # Test whether there are any uncommitted changes in the working
  # directory.
  def no_changes_pending?
    %x(git status --porcelain).split("\n").length == 0
  end

  def increment_patch_version
    tag = ReleaseTag.latest
    tag.patch += 1
    tag
  end

  def versions_hash
    if File.file?(fetch(:versions_path))
      YAML.load_file(fetch(:versions_path))
    else
      {}
    end
  end

  def update_versions_file(tag)
    File.write(fetch(:versions_path), versions_hash.merge(fetch(:stage).to_s => tag.to_s).to_yaml.to_s)
  end

  def yes?(prompt_msg)
    ask(:proceed, prompt_msg + ' [y/N]', default: 'y')
    fetch(:proceed) == 'y'
  end
end
