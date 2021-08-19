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

require 'i18n/backend'
require 'shellwords'
require 'active_model'

require 'flight_configuration'
require_relative 'errors'

module FlightWebSuite
  class Configuration
    extend FlightConfiguration::DSL

    include ActiveModel::Validations

    application_name 'web-suite'

    attribute :flight_command, default: 'bin/flight',
              transform: relative_to(ENV.fetch('flight_ROOT', '/opt/flight'))
    attribute :cert_gen_command,
              default: ->(config) { "#{config.flight_command} www cert-gen" },
              transform: ->(s) { Shellwords.split(s) }
    attribute :config_command,
              default: ->(config) { "#{config.flight_command} config" },
              transform: ->(s) { Shellwords.split(s) }
    attribute :service_command,
              default: ->(config) { "#{config.flight_command} service" },
              transform: ->(s) { Shellwords.split(s) }

    attribute :services, default: 'console-api,desktop-restapi,file-manager-api,job-script-api,login-api,www',
              transform: ->(s) { s.split(',') }

    attribute :log_path, required: false,
              default: 'var/log/web-suite/.log',
              transform: ->(path) do
                if path
                  relative_to(root_path).call(path).tap do |full_path|
                    FileUtils.mkdir_p File.dirname(full_path)
                  end
                else
                  $stderr
                end
              end

    attribute :log_level, default: 'warn'
    validates :log_level, inclusion: {
      within: %w(fatal error warn info debug disabled),
      message: 'must be one of fatal, error, warn, info, debug or disabled'
    }
  end
end
