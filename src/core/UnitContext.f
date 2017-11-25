!
! A unit testing library for Fortran
!
! The MIT License
!
! Copyright 2011-2016 Andrey Pudov
!
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the 'Software'), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in
! all copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
! THE SOFTWARE.
!

submodule (Unit) UnitContext

    implicit none

    type(UnitContext), pointer :: instance

contains
    module subroutine init_context()
        type(ConsoleLogger), pointer :: console
        type(JSONLogger),    pointer :: json

        type(ArgumentsParser) parser
        character(len=128)    filename

        if (.not. associated(instance)) then
            allocate(instance)
            call parser%parse()

            select case(parser%getLoggerType())
            case (LOGGER_JSON)
                filename = parser%getLoggerFile()
                allocate(json)

                call json%init()
                instance%logger => json
            case default
                allocate(console)

                call console%init()
                instance%logger => console
            end select
        end if
    end subroutine

    module subroutine clean_context()
        if (.not. associated(instance)) then
            deallocate(instance%logger)
            deallocate(instance)
        end if
    end subroutine

    module function getLogger_context() result(value)
        class(UnitLogger),  pointer :: value

        call init_context()
        value => instance%logger
    end function

    module function getRunner_context() result(value)
        class(UnitRunner), pointer :: value

        call init_context()
        value => instance%runner
    end function

    module function getSuite_context() result(value)
        class(UnitSuite), pointer :: value

        call init_context()
        value => instance%suite
    end function

    module function getCase_context() result(value)
        class(UnitCaseEntry), pointer :: value

        call init_context()
        value => instance%case
    end function

    module subroutine setRunner_context(runner)
        class(UnitRunner), pointer, intent(in) :: runner

        call init_context()
        instance%runner => runner
    end subroutine

    module subroutine setSuite_context(suite)
        class(UnitSuite), pointer, intent(in) :: suite

        call init_context()
        instance%suite => suite
    end subroutine

    module subroutine setCase_context(case)
        class(UnitCaseEntry), pointer, intent(in) :: case

        call init_context()
        instance%case => case
    end subroutine
end submodule
