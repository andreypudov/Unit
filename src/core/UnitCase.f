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

submodule (Unit) UnitCase

    implicit none

contains
    module subroutine init_case(self, name)
        class(UnitCase), intent(in out)        :: self
        character(len=*), optional, intent(in) :: name

        self%list => null()
        self%last => null()

        if (present(name)) then
            allocate(character(len(name)) :: self%name)
            self%name = name
        else
            allocate(character(1) :: self%name)
            self%name = ''
        end if
    end subroutine

    module subroutine clean_case(self)
        class(UnitCase), intent(in out)   :: self
        type(UnitProcedureEntry), pointer :: entry

        do while (associated(self%list))
            entry => self%list
            self%list => self%list%next

            deallocate(entry)
        end do

        deallocate(self%name)
    end subroutine

    module subroutine add_case(self, procedure, name)
        class(UnitCase), intent(in out)               :: self
        procedure(UnitProcedure), pointer, intent(in) :: procedure
        character(len=*),        optional, intent(in) :: name

        type(UnitProcedureEntry), pointer :: entry
        type(UnitProcedureEntry), pointer :: previous

        allocate(entry)
        entry%next      => null()
        entry%procedure => procedure

        if (present(name)) then
            allocate(character(len(name)) :: entry%name)
            entry%name = name
        else
            allocate(character(1) :: entry%name)
            entry%name = ''
        end if

        if (.not. associated(self%last)) then
            self%list => entry
        else
            previous      => self%last
            previous%next => entry
        end if

        self%last => entry
    end subroutine

    module subroutine run_case(self, resume)
        class(UnitCase), target, intent(in out) :: self
        logical,       optional, intent(in)     :: resume

        type(UnitProcedureEntry),  pointer :: entry
        class(UnitCase),           pointer :: case
        class(UnitProcedureEntry), pointer :: procedure
        class(UnitProcedureEntry), pointer :: procedureOld
        class(UnitLogger),         pointer :: logger

        type(UnitContext) context
        logical           resuming
        logical           processed

        ! set resume option
        if (present(resume)) then
            resuming = resume
        else
            resuming = .false.
        end if

        case   => self
        logger => context%getLogger()

        call context%setCase(case)
        call logger%log(TYPE_CASE, self%name)

        entry     => self%list
        processed =  .false.

        do while (associated(entry))
            procedure    => entry
            procedureOld => context%getProcedure()
            if ((resuming)) then
                if (associated(procedureOld, procedure)) then
                    processed = .true.
                    entry => entry%next
                    cycle
                else
                    if (.not. processed) then
                        entry => entry%next
                        cycle
                    else
                        call context%setProcedure(procedure)
                    end if
                end if
            end if

            call logger%log(TYPE_PROCEDURE, entry%name)
            call entry%procedure(self)

            entry => entry%next
        end do
    end subroutine
end submodule
