!
! A unit testing library for Fortran
!
! The MIT License
!
! Copyright 2011-2017 Andrey Pudov
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

submodule (Logger) JSONLogger

    implicit none

    integer, parameter :: TERMINAL_WIDTH = 80

contains
    module subroutine init_JSONLogger(self)
        class(JSONLogger), intent(in out) :: self

        call self%UnitLogger%init()

        self%case   = 0
        self%passed = 0
        self%failed = 0
    end subroutine

    module subroutine clean_JSONLogger(self)
        class(JSONLogger), intent(in out) :: self

        call self%UnitLogger%clean()
    end subroutine

    module subroutine log_JSONLogger(self, type, name, details, status)
        class(JSONLogger),          intent(in out) :: self
        integer,                    intent(in)     :: type
        character(len=*),           intent(in)     :: name
        character(len=*), optional, intent(in)     :: details
        logical,          optional, intent(in)     :: status

        character(len=16) buffer
        character(len=80) title

        real now

        select case(type)
        case(TYPE_RUNNER)
            self%case   = 0
            self%passed = 0
            self%failed = 0

            print '(A)', name
            call printSeparator()

            call cpu_time(self%finish)
        case(TYPE_SUITE)
            call cpu_time(now)
            self%case = self%case + 1

            write (buffer, '(F12.3)') now - self%finish
            write (title, '(I0,1X,A)') self%case, name
            write (*, '(A72,1X,A,A,A)') adjustl(title), &
                '[', trim(adjustl(buffer)), ']'

            self%finish = now
        case(TYPE_CASE)
            ! TODO add error handling
            if (status) then
                self%passed = self%passed + 1
                buffer      = 'OK'
                title       = name

                ! no output for success cases
                return
            else
                self%failed = self%failed + 1
                buffer      = 'FAILED'
                title       = name

                if (len(trim(details)) > 0) then
                    title  = name // ' [' // trim(adjustl(details)) // ']'
                end if
            end if

            print '(4X,A70,A6)', title, trim(adjustl(buffer))
        case(TYPE_RESULT)
            call cpu_time(self%finish)

            call printSeparator()
            write (buffer, '(F12.3)') self%finish - self%start
            print '(A,A,A,A,I0,A,I0,A,I0)', &
                'Tests completed in ', trim(adjustl(buffer)), ' seconds. ', &
                'Total: ', (self%passed + self%failed), &
                    ', passed: ', self%passed, &
                    ', failed: ',  self%failed
        end select
    end subroutine

    subroutine printSeparator()
        integer index

        do index = 1, TERMINAL_WIDTH
            write (*, '(A)', advance = 'no') '-'
        end do

        print '(A)', ''
    end subroutine
end submodule
