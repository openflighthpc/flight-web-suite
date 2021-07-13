#==============================================================================
# Copyright (C) 2021-present Alces Flight Ltd.
#
# This file is part of Flight Web Suite.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Web Suite is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Web Suite. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Web Suite, please visit:
# https://github.com/openflighthpc/flight-web-suite
#==============================================================================

module FlightWebSuite
  module Commands
    class Domain < Command
      def self.get(_a, opts, _c)
        new(['get', 'web-suite.domain'], opts).run!
      end

      def self.set(args, opts, _)
        new(['set', 'web-suite.domain', args.first], opts).run!
      end

      def run
        cmd = [*Flight.config.config_command, *args]
        str = cmd.join(' ')
        Flight.logger.info "Running: #{str}"
        out, err, status = Open3.capture3(*cmd)
        Flight.logger.debug <<~CMD.chomp

          COMMAND: #{str}
          STATUS: #{status.to_i}
          STDOUT:
          #{out}
          STDERR:
          #{err}
        CMD
        raise CommandError, "Failed to run command: #{str}" unless status.success?
        out
      end
    end
  end
end
