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
    class GetDomain < Command
      def self.get(args, opts, _)
        new(args, opts).run!
      end

      def run
        cmd = [*Flight.config.config_command, 'get', 'web-suite.domain']
        str = cmd.join(' ')
        Flight.logger.info "Running: #{str}"
        out, err, status = Open3.capture3(*cmd)
        log_command(str, status, out, err)
        raise CommandError, "Failed to run command: #{str}" unless status.success?
        puts out
      end
    end
  end
end
