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

require 'open3'
require 'pastel'

module FlightWebSuite
  class Command
    attr_accessor :args, :opts

    def initialize(args, opts)
      @args = args.freeze
      @opts = opts
    end

    def run!
      Flight.logger.info "Running: #{self.class}"
      run
      Flight.logger.info 'Exited: 0'
    rescue => e
      if e.respond_to? :exit_code
        Flight.logger.fatal "Exited: #{e.exit_code}"
      else
        Flight.logger.fatal 'Exited non-zero'
      end
      Flight.logger.debug e.backtrace.reverse.join("\n")
      Flight.logger.error "(#{e.class}) #{e.message}"
      raise e
    end

    def run
      raise NotImplementedError
    end

    def pastel
      @pastel ||= Pastel.new
    end

    def log_command(cmd, status, out, err)
      Flight.logger.debug <<~CMD.chomp

        COMMAND: #{cmd}
        STATUS: #{status.to_i}
        STDOUT:
        #{out}
        STDERR:
        #{err}
      CMD
    end
  end
end
