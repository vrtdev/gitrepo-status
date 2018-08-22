require 'gitrepo/status/version'
require 'rugged'
require 'json'

# Class Gitrepo
class Gitrepo
  # Class Gitrepo::Status
  class Status
    def initialize(opt = {})
      @path = opt.fetch(:path)
      @report_branches = opt[:report_branches] || %w[master]
      repo
    end

    def repo
      return @repo if @repo
      @repo = Rugged::Repository.discover(@path)
      @basepath = repo.path.chomp('/.git/')
      @repo
    end

    def fetch_all
      # libgit2 and https... a dificult story... :-(
      # remotes.each do |remote|
      #   repo.fetch remote.name
      # end
      cmd1 = 'git branch -r | grep -v "\->" | while read remote; do git branch --track "${remote#origin/}" "$remote" > /dev/null 2>&1; done'
      cmd2 = 'git fetch --all > /dev/null 2>&1'
      Dir.chdir(@path) do
        `#{cmd1}`
        `#{cmd2}`
      end
    end

    def puppet_module?
      !repo.index.get('metadata.json').nil?
    end

    def branchnames
      branches_txt = ''
      Dir.chdir(@path) do
        branches_txt = `git branch --contains HEAD | grep -v 'detached at'`
      end
      branches = branches_txt.split("\n").map(&:strip)
      branches.insert(0, branches.delete('master')) if branches.include?('master')
      select_branches(branches)
    end

    def select_branches(branches)
      return branches if @report_branches.empty?
      b = branches.select { |e| @report_branches.include?(e) }
      return b unless b.empty?
      branches
    end

    def ahead_behind
      branches = {}
      branchnames.each do |branch|
        branch = "origin/#{branch}"
        branches[branch] = repo.ahead_behind(repo.head.target_id, branch)
      end
      branches
    end

    def puppet_module_info
      blob = repo.blob_at(repo.head.target_id, 'metadata.json')
      current_metadata = JSON.parse(blob.content)
      diff = {}
      branchnames.each do |branch|
        blob = repo.blob_at(repo.branches[branch].target_id, 'metadata.json')
        branch_metadata = JSON.parse(blob.content)
        branch_diff = deep_diff(current_metadata, branch_metadata)
        diff[branch] = branch_diff unless branch_diff.empty?
      end
      diff
    end

    def test
      require 'awesome_print'
      # puts '--- repo.methods ---'
      # ap repo.methods
      puts '--- repo.path ---'
      ap repo.path

      ap repo.index.get('metadata.json')

      puts '--- repo.last_commit ---'
      ap repo.last_commit.tree_id

      puts "Is Puppet Module? (has '/metadata.json'?) : #{puppet_module?}"
      head = repo.head
      puts '--- repo.head ---'
      ap head

      # sha1 hash of the newest commit
      head_sha = head.target_id
      puts '--- repo.head.target_id ---'
      ap head_sha

      ap repo.ahead_behind(head_sha, 'origin/master')

      puts '--- repo remotes ---'
      repo.remotes.each do |remote|
        # ap remote.methods
        ap remote.url
      end

      puts '--- repo branch ---'
      repo.branches.each do |branch|
        # ap branch.methods
        ap branch.name
        ap branch.head?
        ap branch.upstream
      end

      # # the commit message associated the newest commit
      # commit = repo.lookup(head_sha)
      # puts '--- repo.lookup(repo.head.target_id) ---'
      # pp commit
      #
      # puts '--- repo object methods ---'
      # ap repo.methods
      #
      puts '--- repo remotes ---'
      repo.remotes.each do |remote|
        # ap remote.methods
        ap remote.name
        ap remote.url
      end
      #
      # puts '--- repo branch ---'
      # repo.branches.each do |branch|
      #   ap branch.methods
      #   ap branch.name
      # end
    end

    def deep_diff(a, b)
      (a.keys | b.keys).each_with_object({}) do |k, diff|
        if a[k] != b[k]
          if a[k].is_a?(Hash) && b[k].is_a?(Hash)
            diff[k] = deep_diff(a[k], b[k])
          else
            diff[k] = [a[k], b[k]]
          end
        end
        diff
      end
    end
  end
end
