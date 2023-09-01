.data
    PromptForPlaintext:
        .asciz  "Please enter the plaintext: "
        lenPromptForPlaintext = .-PromptForPlaintext

    PromptForShiftValue:
        .asciz  "Please enter the shift value: "
        lenPromptForShiftValue = .-PromptForShiftValue

    Newline:
        .asciz  "\n"

    ShiftValue:
        .int    0
.bss
    .comm   buffer, 102     # Buffer to read in plaintext/output ciphertext
    .comm   intBuffer, 4    # Buffer to read in shift value
                            # (assumes value is 3 digits or less)

.text

    .globl _start

    .type PrintFunction, @function
    .type ReadFromStdin, @function
    .type GetStringLength, @function
    .type AtoI, @function
    .type CaesarCipher, @function


    PrintFunction:
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        # Write syscall
        movl $4, %eax           # syscall number for write()
        movl $1, %ebx           # file descriptor for stdout
        movl 8(%ebp), %ecx      # Address of string to write
        movl 12(%ebp), %edx     # number of bytes to write
        int $0x80

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return

    ReadFromStdin:
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        # Read syscall
        movl $3, %eax
        movl $0, %ebx
        movl 8(%ebp), %ecx      # address of buffer to write input to
        movl 12(%ebp), %edx     # number of bytes to write
        int  $0x80

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return


    GetStringLength:

        # Strings which are read through stdin will end with a newline character. (0xa)
        # So look through the string until we find the newline and keep a count
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        movl 8(%ebp), %esi      # Store the address of the source string in esi
        xor %edx, %edx          # edx = 0

        Count:
			inc %edx            # increment edx
            lodsb               # load the first character into eax
            cmp $0xa, %eax  	# compare the newline character vs eax
            jnz Count           # If eax != newline, loop back

        dec %edx                # the loop adds an extra one onto edx
        movl %edx, %eax          # return value

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return


    
    AtoI:
        pushl %ebp          # store the current value of EBP on the stack
        movl %esp, %ebp     # Make EBP point to top of stack

        movl 8(%ebp), %esi  # Store the address of the source string in esi
        xorl %eax, %eax     # Initialize eax to 0
        xorl %edx, %edx     # Initialize edx to 0
        jmp SkipLeadingZeros

        # While loop for processing string digits
        ProcessDigit:
            subb $0x30, (%esi)  # subtract 0x30 from the ascii value to convert it to int
            imull $10, %eax     # multiply eax by 10
            addl %edx, %eax     # add the current digit to eax
            inc %esi            # increment the pointer to the next character
            xorl %edx, %edx     # clear edx for the next iteration

        # Skip over leading zeros
        SkipLeadingZeros:
            movb (%esi), %dl
            cmpb $0x30, %dl
            jb EndAtoI
            cmpb $0x39, %dl
            ja EndAtoI
            jmp ProcessDigit

        # Return result in eax
        EndAtoI:
            movl %ebp, %esp     # Restore the old value of ESP
            popl %ebp           # Restore the old value of EBP
            ret                 # return

    CaesarCipher:
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        movl 8(%ebp), %esi      # Store the address of the buffer in esi
        movl 12(%ebp), %ebx     # Store the shift value in ebx

        # Loop for shifting the characters
        ShiftLoop:
            movb (%esi), %al     # Load character into al
            cmpb $0xa, %al       # Check if we reached the end of the input string
            je EndShiftLoop      # If yes, end the loop
            addb %bl, %al        # Shift the character
            cmpb $0x7a, %al      # Check if the character is > 'z'
            jg WrapAround        # If yes, wrap it around
            cmpb $0x61, %al      # Check if the character is < 'a'
            jl WrapAround        # If yes, wrap it around
            movb %al, (%esi)     # Store the shifted character
            inc %esi             # Increment the pointer to the next character
            jmp ShiftLoop
		CheckNullCharacter:
			movb (%esi), %al
			cmpb $0x0, %al
			je EndNullCharacter
			jmp ShiftLoop

		EndNullCharacter:
			inc %esi
			jmp CheckNullCharacter
        WrapAround:
            subb $0x20, %al      # Wrap the character around
            movb %al, (%esi)     # Store the shifted character
            inc %esi             # Increment the pointer to the next character
            jmp ShiftLoop

        EndShiftLoop:
            movl %ebp, %esp     # Restore the old value of ESP
            popl %ebp           # Restore the old value of EBP
           
 



    _start:

        # Print prompt for plaintext
        pushl   $lenPromptForPlaintext
        pushl   $PromptForPlaintext
        call    PrintFunction
        addl    $8, %esp

        # Read the plaintext from stdin
        pushl   $102
        pushl   $buffer
        call    ReadFromStdin
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp


        # Get input string and adjust the stack pointer back after
        pushl   $lenPromptForShiftValue
        pushl   $PromptForShiftValue
        call    PrintFunction
        addl    $8, %esp

        # Read the shift value from stdin
        pushl   $4
        pushl   $intBuffer
        call    ReadFromStdin
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp



        # Convert the shift value from a string to an integer.
        # FILL IN HERE
		call	AtoI
		addl	$8, %esp


        # Perform the caesar cipheR
        # FILL IN HERE
		call	CaesarCipher
		addl	$8, %esp


        # Get the size of the ciphertext
        # The ciphertext must be referenced by the 'buffer' label
        pushl   $buffer
        call    GetStringLength
        addl    $4, %esp

        # Print the ciphertext
        pushl   %eax
        pushl   $buffer
        call    PrintFunction
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp

        # Exit the program
        Exit:
            movl    $1, %eax
            movl    $0, %ebx
            int     $0x80