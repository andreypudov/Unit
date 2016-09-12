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

submodule (Logger) ConsoleLogger

    implicit none

    integer, parameter :: TERMINAL_WIDTH = 80

contains
    module subroutine init_consoleLogger(self, suiteName)
        class(ConsoleLogger), target, intent(in out) :: self
        character(len=*),     intent(in)     :: suiteName

        if (.not. associated(consoleLoggerInstance)) then
            call self%UnitLogger%init(suiteName)

            print '(A)', self%suiteName
            call printSeparator()

            consoleLoggerInstance => self
        end if
    end subroutine

    module subroutine clean_consoleLogger(self)
        class(ConsoleLogger), intent(in out) :: self

        character(len=16) buffer
        real finish

        call cpu_time(finish)

        call printSeparator()
        write (buffer, '(F12.3)') finish - self%start
        print '(A,A,A)', 'Tests completed in ', trim(adjustl(buffer)), ' seconds.'

        call self%UnitLogger%clean()
        consoleLoggerInstance => null()
    end subroutine

    module subroutine log_consoleLogger(self, message)
        class(ConsoleLogger), intent(in) :: self
        character(len=*), intent(in)     :: message

        print '(A)', message
    end subroutine

    subroutine printSeparator()
        integer index

        do index = 1, TERMINAL_WIDTH
            write (*, '(A)', advance = 'no') '-'
        end do

        print '(A)', ''
    end subroutine
end submodule
