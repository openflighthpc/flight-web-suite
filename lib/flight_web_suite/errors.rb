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
  class Error < RuntimeError
    def self.define_class(code)
      Class.new(self).tap do |klass|
        klass.instance_variable_set(:@exit_code, code)
      end
    end

    def self.exit_code
      @exit_code || begin
        superclass.respond_to?(:exit_code) ? superclass.exit_code : 2
      end
    end

    def exit_code
      self.class.exit_code
    end
  end

  InternalError = Error.define_class(1)
  GeneralError = Error.define_class(2)
  InputError = GeneralError.define_class(3)
  CommandError = GeneralError.define_class(6)
  DuplicateError = GeneralError.define_class(7)

  class InteractiveOnly < InputError
    MSG = 'This command requires an interactive terminal'

    def initialize(msg = MSG)
      super
    end
  end

  MissingError = GeneralError.define_class(20)
end
