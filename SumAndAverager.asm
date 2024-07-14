TITLE Sum and Average Calculator

; Last Modified:			12-08-23
; Description:				This program processes user-entered numbers, converting them from strings
;							to integers and calculating their sum and average. To print each value
;							during program execution, they are again converted from a numerical value
;							to a string. After processing and displaying the first set of numbers, the
;							program will run a similar operation, prompting the user for floating-point
;							values to be processessed in a similar way while utilizing the FPU.
  
INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; First promts the user for input, then stores the user’s input, and number of 
; characters entereed into the two memory locations provided as arguements.
;
; Preconditions: do not use EAX, ECX, EDX as arguments.
;
; Receives:
;		promptAddr		=  array address (input parameter, by reference)
;		bufferAddr		=  (output parameter, by reference)
;		bufferSize		=  (input parameter, by value)
;
; returns:
;		bytesReadAddr	=	number of bytes read (output parameter, by reference)
; ---------------------------------------------------------------------------------
mGetString MACRO promptAddr:REQ, bufferAddr:REQ, bufferSize:REQ, bytesReadAddr:REQ
	push	EAX
	push	ECX
	push	EDX
	; display prompt					; WriteString preconditions:
	mov		EDX, promptAddr				;		EDX = address of string
	call	WriteString
	; read string						; ReadString preconditions:
	mov		EDX, bufferAddr				;		EDX = address of buffer
	mov		ECX, bufferSize				;		ECX = buffer size
	call	ReadString					; ReadString preconditions:
	mov		[bytesReadAddr], EAX		;		EAX = number of characters entered
	; restore regs
	pop		EDX
	pop		ECX
	pop		EAX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints the string stored at the provided memory location using WriteString.
;
; Preconditions: do not use EDX as an argument
;
; Receives:
;		stringAddr	 = array address (input parameter, by reference)
; ---------------------------------------------------------------------------------
mDisplayString MACRO stringAddr:REQ
	push	EDX
  	; display string
	mov		EDX, stringAddr
	call	WriteString
	; restore regs
	pop		EDX
ENDM

; ---------------------------------------------------------------------------------
; Name: mPrintSpacing
;
; Prints a character followed by a space.
;
; Receives:	character  =  immediate value (input, by value)
; ---------------------------------------------------------------------------------
mPrintSpacing MACRO character:REQ
	push	EAX
  	;display string
	mov		al, character
	call	WriteChar
	mov		al, " "
	call	WriteChar
	;restore registers
	pop		EAX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayLineNumber
;
; Prints a number representing the current line of user input. (length - count + 1)
;
; Preconditions: Requires mPringSpacing macro.
;
; Receives:
;		arrayLength	  =   (input, by reference)
;		currentCount  =   (input, by value)
; ---------------------------------------------------------------------------------
mDisplayLineNumber MACRO arrayLength:REQ, currentCount:REQ
	push	EBP
	mov		EBP, ESP
	push	EAX	
	; print new line
	call	Crlf
	; calculate line number	(length - count + 1)
	mov		EAX, arrayLength
	sub		EAX, currentCount
	inc		EAX
	push	EAX								;[ebp+8]  =  SDWORD (input, value)
	call	WriteVal
	mPrintSpacing "."						;macro to print ". "
	;restore registers
	pop		EAX				
	pop		EBP
ENDM

;constants
ARRAYSIZE	=	10							;should be set to 10 by default

.data
	;messages
	msg_intro		BYTE	10, 13, "SUM AND AVERAGE CALCUALTOR:", 10, 13, 
							"Designing low-level I/O procedures", 10, 13,
							"Written by Christian Ritchie", 0
	msg_rules		BYTE	"Please provide 10 signed decimal integers.", 10, 13,
							"Each number needs to be small enough to fit inside a 32 bit register.", 10, 13,
							"After you have finished inputting the raw numbers I will display", 10, 13,
							"a list of the integers, their sum, and their average value.", 10, 13, 0
	msg_prompt		BYTE	"Please enter an signed number: ", 0
	msg_invalid		BYTE	"   ERROR: You did not enter a signed number or your number was too big.", 10, 13,
							"   Please try again: ", 0
	msg_running		BYTE	"   Running Total: ", 0
	msg_showAll		BYTE	10, 13, "You entered the following numbers: ", 10, 13, 0
	msg_showSum		BYTE	10, 13, "The sum of these numbers is: ", 0
	msg_showAvg		BYTE	10, 13, "The truncated average is: ", 0

	;messages 
	msg_divider		BYTE	10, 13, "____________________________________________________________________", 10, 13, 10, 13, 0
	msg_extra		BYTE	10, 13, "Number each line of user input and display a running subtotal.",
							10, 13, 0
	msg_rulesEC		BYTE	"Please provide 10 floating-point numbers. (up to 5 decimal places)", 10, 13,
							"After you have finished inputting the raw numbers I will display", 10, 13,
							"a list of the float values, their sum, and their average value.", 10, 13, 0
	msg_promptEC	BYTE	"Please enter a floating-point number: ", 0
	msg_invalidEC	BYTE	"   ERROR: You did either not enter a floating-point number, or your", 10, 13,
							"   number was too big, or included more than 5 decimal places.", 10, 13,
							"   Please try again: ", 0
	msg_goodbye		BYTE	10, 13, 10, 13, "GOOD job. Thanks for playing.", 10, 13, 10, 13, 0
	;input and statistics
	array_numbers	SDWORD	ARRAYSIZE dup(?)
	numbersSum		SDWORD	0			;stores running total, then final sum
	numbersAvg		SDWORD  ?
	;input and statistics 
	array_floats	REAL8	ARRAYSIZE dup(?)
	floatsSum		REAL8	0.0			;stores running total, then final sum
	floatsAvg		REAL8	?

.code
main PROC

	;display Title, Author, extra credit, and instructions.
	mDisplayString OFFSET msg_intro		;intro
	mDisplayString OFFSET msg_divider	;______________________
	mDisplayString OFFSET msg_rules		;rules
	mDisplayString OFFSET msg_extra		

; ------------------------------------------------------------------------
; 1. Get 10 valid integers from the user using a loop that calls ReadVal.
; ------------------------------------------------------------------------
	;initialize count and array address for _GetVals loop
	mov		ECX, LENGTHOF array_numbers
	mov		ESI, OFFSET array_numbers	;register indirect addressing

_GetVals:
	;Display numbered user input
	mDisplayLineNumber ARRAYSIZE, ECX	

	;readval arguments
	push	OFFSET numbersSum			;[ebp+20]=  sum address (input/output, reference)
	push	OFFSET msg_invalid			;[ebp+16]  =  invalid msg address (input, reference)
	push	OFFSET msg_prompt			;[ebp+12]  =  prompt msg address (input, reference)
	push	ESI							;[ebp+8]   =  SDWORD (input/output, reference)
	call	ReadVal
	add		ESI, 4						;get next address

	;Display running total
	mDisplayString OFFSET msg_running
	push	numbersSum
	call	WriteVal
	loop	_GetVals

; ------------------------------------------------------------------------
; 2. Display the integers, their sum, and their truncated average.
; ------------------------------------------------------------------------
	;print 'numbers entered.." message
	call	Crlf
	mDisplayString OFFSET msg_showAll

	;print numbers entered
	mov		ECX, ARRAYSIZE
	mov		ESI, OFFSET array_numbers	;register indirect addressing
	jmp		_PrintNum					;skip initial ", " print
_PrintSpacing:
	mPrintSpacing ","					;macro to print ", "
_PrintNum:
	push	[ESI]
	call	WriteVal
	add		ESI, 4
	loop	_PrintSpacing

	;generate sum and truncated average
	push	OFFSET numbersAvg			;[ebp+20]  =  address of average (output, by reference)
	push	OFFSET numbersSum			;[ebp+16]  =  address of sum (output, by reference)
	push	OFFSET array_numbers		;[ebp+12]  =  address of number array (input, by reference)
	push	ARRAYSIZE					;[ebp+8]   =  length of the number array (input, by value)
	call	getStatistics

	;print sum
	mDisplayString OFFSET msg_showSum
	push	numbersSum				
	call	WriteVal

	;print truncated average
	mDisplayString OFFSET msg_showAvg
	push	numbersAvg
	call	WriteVal

; ------------------------------------------------------------------------
;   Separate code block to demo ReadFloatVal and WriteFloatVal.
; ------------------------------------------------------------------------
	mDisplayString OFFSET msg_divider	;______________________
	mDisplayString OFFSET msg_rulesEC	;I LOVE FLOATS SO MUCH
	
; ------------------------------------------------------------------------
; 1. Get 10 valid integers from the user. (ReadFloatVal)
; ------------------------------------------------------------------------
	;initialize count and array address for _GetVals loop
	mov		ECX, LENGTHOF array_floats
	mov		ESI, OFFSET array_floats	;register indirect addressing

_GetFloatVals:
	;Display numbered user input
	mDisplayLineNumber ARRAYSIZE, ECX

	;readval arguments
	push	OFFSET floatsSum			;[ebp+20]  =  sum address (input/output, reference)
	push	OFFSET msg_invalidEC		;[ebp+16]  =  invalid msg address (input, reference)
	push	OFFSET msg_promptEC			;[ebp+12]  =  prompt msg address (input, reference)
	push	ESI							;[ebp+8]   =  REAL8 (input/output, reference)
	call	ReadFloatVal
	add		ESI, TYPE array_floats		;get next address

	;Display running total
	mDisplayString OFFSET msg_running
	push	OFFSET floatsSum			; [ebp+8]  =  REAL8 (input, reference)
	call	WriteFloatVal
	loop	_GetFloatVals
	call	Crlf

; ------------------------------------------------------------------------
; 2. Display the floats, their sum, and their truncated average.
; ------------------------------------------------------------------------
	mDisplayString OFFSET msg_showAll
	mov		ECX, ARRAYSIZE
	mov		ESI, OFFSET array_floats	;register indirect addressing
	jmp		_PrintFloat					;skip initial ", " print

_PrintFloatSpacing:
	mPrintSpacing ","					;macro to print ", "
_PrintFloat:
	push	ESI
	call	WriteFloatVal
	add		ESI, TYPE array_floats
	loop	_PrintFloatSpacing

	;generate sum and truncated average
	push	OFFSET floatsAvg			;[ebp+20]  =  address of average (output, by reference)
	push	OFFSET floatsSum			;[ebp+16]  =  address of sum (output, by reference)
	push	OFFSET array_floats			;[ebp+12]  =  address of number array (input, by reference)
	push	ARRAYSIZE					;[ebp+8]   =  length of the number array (input, by value)
	call	getFloatStatistics

	;print sum
	mDisplayString OFFSET msg_showSum
	push	OFFSET floatsSum
	call	WriteFloatVal

	;print truncated average
	mDisplayString OFFSET msg_showAvg
	push	offset floatsAvg
	call	WriteFloatVal

	;say goodbye
	mDisplayString OFFSET msg_goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Reads a string of ASCII characters entered by the user, validates that they
; correctly represent a signed decimal number, then converts them to a SDWORD.
; If an invalid input is detected, the user is prompted to re-enter the value.
;
; Preconditions: None
;
; Postconditions: SDWORD memory address is updated with the result.
;				  The value stored in the sum address is updated to
;				  contain its value + the resulting SDWORD.
;
; Receives:
;		[ebp+20]  =  sum address (input/output, reference)
;		[ebp+16]  =  invalid msg address (input, reference)
;		[ebp+12]  =  prompt msg address (input, reference)
;		 [ebp+8]  =  SDWORD memory address (input/output, reference)
;
; Returns: None.
; ---------------------------------------------------------------------------------
ReadVal PROC
	LOCAL bytesRead:DWORD, resultBuffer:SDWORD, arrayBuffer[42]:BYTE		
	;local variables: [ebp-4], [ebp-8], [ebp-50] 
	pushad
; ------------------------------------------------------------------------
; 1. Invoke the mGetString macro (see parameter requirements above) 
;	 to get user input in the form of a string of digits.
; ------------------------------------------------------------------------
	mov		EBX, [ebp+12]				;EBX: prompt (initial attempt)
	jmp		_loadArguments
_RePrompt:
	mov		EBX, [ebp+16]				;EBX - prompt (re-enter value)
_loadArguments:
	mov		ESI, EBP				
	sub		ESI, 50						;ESI: arrayBuffer address [ebp-50]
	mov		EDI, EBP				
	sub		EDI, 4						;EDI: bytesRead address [ebp-4]

	mGetString EBX, ESI, SIZEOF arrayBuffer, EDI
	; params:  promptAddr, bufferAddr, bufferSize, bytesReadAddr (return)
	; preconditions:  do not use EAX, ECX, EDX as arguments

	; re-prompt if the user enters nothing (empty input)
	cmp		bytesRead, 0
	je		_rePrompt
	
; ------------------------------------------------------------------------
; 2. Convert (using string primitives) the string of ascii digits to its
;	 numeric value representation (SDWORD), validating the user’s input 
;	 is a valid number (no letters, symbols, etc).
;
;	 Reads characters from back to front, converting to digit, validating,
;	 then using a '10s place' (EDX) counter, multiplies and adds to sum.
; ------------------------------------------------------------------------
	; initialize variables
	mov		resultBuffer, 0				;Initialize result buffer to 0
	mov		ECX, bytesRead				;ECX: counter
	mov		EBX, 0						;EBX: 10s place multiplier
	add		ESI, bytesRead				;ESI: last string character index (sum storage)
	dec		ESI

_ConversionLoop:
	std									;Set Direction Flag (decrement pointer)
	lodsb								;Load element to AL and move pointer

	; check for sign on first byte
	cmp		ECX, 1						;check if currently on first byte
	jg		_ValidateDigit
	cmp		bytesRead, 1				;jump to digit validation if only 1 byte read
	je		_ValidateDigit				;(edge case for single byte entries of "+" or "-")
	cmp		AL, '+'
	je		_ValidationComplete
	cmp		AL, '-'
	jne		_ValidateDigit
	neg		resultBuffer				;convert to negative value
	jmp		_ValidationComplete

	; check that character is between 0 and 9
_ValidateDigit:
	cmp		AL, '9'						;test: char is <= 9
	jg		_RePrompt
	cmp		AL, '0'						;test: char is >= 0
	jb		_RePrompt
	sub		AL, '0'						;convert char to digit (subtract 48d)
	movsx	EAX, AL						;store digit

	; calclate digit's value at place value  (multiply by 10^n)
_FindPlaceValue:
	push	ECX							;preserve counter
	mov		ECX, EBX					;counter = place value count
	cmp		ECX, 0						;skip loop if in the 1s' place (0)
	je		_EndPlaceValue
_PlaceValueLoop:
	imul	EAX, 10
	loop	_PlaceValueLoop
_EndPlaceValue:
	pop		ECX							;restore counter
	inc		EBX							;increment place count

	; add result to subtotal
	add		resultBuffer, EAX
	jo		_RePrompt					;check for overflow
	loop	_ConversionLoop

_ValidationComplete:
; ------------------------------------------------------------------------
; 3. Store this one value in a memory variable (output, reference). 
;    Store in memory variable as running average
; ------------------------------------------------------------------------
	mov		EBX, resultBuffer
	; Store final result to memory
	mov		EAX, [EBP+8]
	mov		[EAX], EBX					
	; Add final result to running total
	mov		EAX, [EBP+20]
	add		[EAX], EBX

	; restore registers
	popad
	ret		16
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a SDWORD value to its ASCII string representation and displays it by
; calling mDisplayString, representing negative values with a '-' sign prefixed.
; 
; Postconditions: none.
;
; Receives:
;		 [ebp+8]  =  SDWORD (input, value)
;
; returns: None.
; ---------------------------------------------------------------------------------
WriteVal PROC
	LOCAL	stringBuffer[42]:BYTE
	pushad

; ------------------------------------------------------------------------
; 1. Convert a numeric SDWORD value (input parameter, by value) to a 
;	 string of ASCII digits using sequential division by 10.
; ------------------------------------------------------------------------
	; initialize variables
	mov		EAX, [EBP+8]				;EAX - SDWORD
	mov		ECX, 0						;ECX - character count
	mov		EDI, EBP					; 
	sub		EDI, SIZEOF stringBuffer	;EDI - buffer element address (init to first)

	; check for negative value
	cmp		EAX, 0
	jge		_ConvertToString
	neg		EAX							;if negative: make SDWORD positive

	; if negative: store '-' at stringBuffer[0]
	push	EAX
	mov		AL, '-'
	cld									;clear Direction Flag (increments pointers)
	stosb								;store AL in address and move pointer
	pop		EAX

_ConvertToString:
	push	EDI							;preserve current address (0-index or 1-index)
	add		EDI, SIZEOF stringBuffer-1	;set address to last byte
	std									;set Direction Flag (decrement pointers)
_Conversionloop:						;(sequential division by 10)
	mov     EDX, 0						;clear EDX; precondition: EDX:EAX - Dividend
    mov     EBX, 10
    div     EBX							;Postcondition: EAX - Quotient, EDX - Remainder

	; store remainder as ascii
	push	EAX							;preserve quotient
	add		DL, '0'						;add 48d to DL to get ascii-equivalent
	mov		AL, DL
	stosb								;load element to AL and move pointer
	pop		EAX							;restore quotient
	inc		ECX							;character count +1

	; loop if: quotient > 0
	cmp		EAX, 0						
	jg		_Conversionloop

	; move string result to beginning of string
	mov		ESI, EDI					
	inc		ESI							;change destiniation to source
	pop		EDI							;restore start address (0-index or 1-index)
	cld									;clear Direction Flag (increments pointers)
	rep		movsb

	; Null-terminate string
	mov		AL, 0
	stosb

; ------------------------------------------------------------------------
; 2. Invoke the mDisplayString macro to print the ASCII 
;	 representation of the SDWORD value to the output.
; ------------------------------------------------------------------------
	mov		ESI, EBP					
	sub		ESI, SIZEOF stringBuffer	;ESI - stringBuffer address
	mDisplayString ESI

    ; Restore registers           
	popad
	ret     4
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: getStatistics
;
; Generates the sum and truncated average of all SDWORDs in the provided array,
; storing them in memory addresses provided as a parameters for sum and average.
;
; Preconditions: Array address provided must be filled with at least 1 DWORD.
;
; Postconditions: The sum and truncated average of the input array is stored in 
;				  the memory addresses provided as parameters.
;
; Receives:
;		[ebp+20]  =  address of average (output, by reference)
;		[ebp+16]  =  address of sum (output, by reference)
;		[ebp+12]  =  address of number array (input, by reference)
;		 [ebp+8]  =  length of the number array (input, by value)
;
; returns: None.
; ---------------------------------------------------------------------------------
getStatistics PROC
	push	EBP
	mov		EBP, ESP
	pushad

	; generate sum
	mov		ECX, [ebp+8]		; ECX: length of number array
	mov		ESI, [ebp+12]		; ESI: address of memory array
	mov		EAX, 0
_SumLoop:
	add		EAX, [ESI]
	add		ESI, 4
	loop	_SumLoop
	; store sum
	mov		EDI, [EBP+16]
	mov		[EDI], EAX

	; generate truncated average
	mov		ECX, [ebp+8]		; ECX: length of number array
	cdq							; EDX=FFFFFFFFh
	idiv	ECX
	; store truncated average
	mov		EDI, [EBP+20]
	mov		[EDI], EAX

	popad
	pop	EBP
	ret 16
getStatistics ENDP


; ---------------------------------------------------------------------------------
; Name: ReadFloatVal 
;
; Reads a string of ASCII characters entered by the user, validates they
; correctly represent a floating point number, then converts them to a REAL4.
; If an invalid input is detected, the user is prompted to re-enter the value.
;
; Preconditions: None
;
; Postconditions: REAL4 memory address is updated with the result.
;				  The value stored in the sum address is updated to
;				  contain its value + the resulting SDWORD.
;
; Receives:
;		[ebp+20]  =  sum address (input/output, reference)
;		[ebp+16]  =  invalid msg address (input, reference)
;		[ebp+12]  =  prompt msg address (input, reference)
;		 [ebp+8]  =  REAL4 memory address (input/output, reference)
;
; Returns: None.
; ---------------------------------------------------------------------------------
ReadFloatVal PROC
	LOCAL bytesRead:DWORD, arrayBuffer[42]:BYTE, floatBuffer:REAL4
	;local variables: [ebp-4], [ebp-46], [ebp-50], [ebp-58]
	pushad
; ------------------------------------------------------------------------
; 1. Invoke the mGetString macro (see parameter requirements above) 
;	 to get user input in the form of a string of digits.
; ------------------------------------------------------------------------
	mov		EBX, [ebp+12]			;EBX: prompt (initial attempt)
	jmp		_loadArguments
_RePrompt:
	mov		EBX, [ebp+16]			;EBX - prompt (re-enter value)
_loadArguments:
	mov		ESI, EBP				
	sub		ESI, 46					;ESI: arrayBuffer address
	mov		EDI, EBP				
	sub		EDI, 4					;EDI: bytesRead address

	mGetString EBX, ESI, SIZEOF arrayBuffer, EDI
	; params:  promptAddr, bufferAddr, bufferSize, bytesReadAddr (return)
	; preconditions:  do not use EAX, ECX, EDX as arguments

	; re-prompt if the user enters nothing (empty input)
	cmp		bytesRead, 0
	je		_rePrompt
	
; ------------------------------------------------------------------------
; 2. Convert (using string primitives) the string of ascii digits to its
;	 float value representation (REAL4), validating the user’s input 
;	 is a valid number (no letters, symbols, etc).
;
;	 Reads characters from back to front, converting to digit, validating,
;	 then using a '10s place' (EDX) counter, multiplies and adds to sum.
; ------------------------------------------------------------------------
	; initialize variables
	finit							;initialize FPU
	mov		floatBuffer, 0			;Initialize result buffer to 0
	mov		ECX, bytesRead			;ECX: counter
	mov		EDX, 0					;leading 0 count (0 = not past decimal)
	mov		floatBuffer, 1			;sign value (+1, positive)
	fild	floatBuffer				
	mov		floatBuffer, 0			;set sum to 0
	fild	floatBuffer				

_ConversionLoop:
	cld								;CLear Direction Flag (increment pointer)
	lodsb							;load element to AL and move pointer

; ------------------------------------------------------------------------
;  Check for sign, handle negatives, and validate a digit is between 0-9
; ------------------------------------------------------------------------
	; check for sign on first byte
	cmp		bytesRead, 1			;jump to digit validation if only 1 byte read
	je		_ValidateDigit			;(edge case for single byte entries of "+" or "-")
	cmp		AL, '-'
	je		_NegativeValue

	; positive Value
	cmp		AL, '+'
	je		_EndInteration
	jmp		_DecimalCheck			;neither '+' nor '-'

	; negative value
_NegativeValue:
	fstp	floatBuffer				;pop sum (currently 0) to make '1' at ST(0)
	fchs							;change '1' to '-1'
	fild	floatBuffer				;push sum (currently 0)
	jmp		_EndInteration

	; Start point for every loop after first
_NewLoop:
	cld								;CLear Direction Flag (increment pointer)
	lodsb							;load element to AL and move pointer

	; check for decimal point
_DecimalCheck:
	cmp		AL, '.'
	jne		_ValidateDigit
	cmp		EDX, 0					;check if decimal was encountered previously
	ja		_RePrompt
	mov		EDX, 1					;past decimal = true (EDX > 0)
	jmp		_EndInteration

	; check that character is between 0 and 9
_ValidateDigit:
	cmp		AL, '9'					;test: char is <= 9
	jg		_RePrompt
	cmp		AL, '0'					;test: char is >= 0
	jb		_RePrompt
	sub		AL, '0'					;convert char to digit (subtract 48d)
	
	jmp		_DecimalCalculation
_JumpToLoopStart:
	jmp		_NewLoop

; ------------------------------------------------------------------------
;  Decimal Calculation:
;  Calculation to convert current digit to its correct decimal value.
;  Leading zero counter's (EDX) value finds the value to divide the
;  current digit by to get its correct value.
;  i.e., EDX: 1 (one leading zero), current digit: 6  =  6/10^1  =  0.6
; ------------------------------------------------------------------------
_DecimalCalculation:
	; check if past decimal point
	cmp		EDX, 0
	je		_WholeValue

	;check if current leading 0s > 10
	cmp		EDX, 6
	jae		_RePrompt
	
	; check if new digit is 0 (skip loop)
	cmp		AL, 0
	inc		EDX						;leading 0 count +1
	je		_EndInteration
	
	;initialize variables
	movsx	EAX, AL		
	mov		floatBuffer, EAX
	fild	floatBuffer				;ST(1) = current digit
	mov		floatBuffer, 1
	fild	floatBuffer				;ST(0) = 10^n
	mov		EAX, EDX				;EAX	= loop counter
	sub		EAX, 1

	; find decimal place value (10^n)
_DecimalValue:
	mov		floatBuffer, 10
	fild	floatBuffer
	fmul
	dec		EAX
	cmp		EAX, 0
	ja		_DecimalValue

	; (digit / 10^n)
	fdiv							
	fadd							;add to subtotal
	jmp		_EndInteration
	
; ------------------------------------------------------------------------
;  Whole Value Calculation:
;  The current sum is multiplied by 10 before adding the current digit. 
; ------------------------------------------------------------------------

_WholeValue:
	; skip place value multiplication if sum == 0
	ftst							;TeST ST(0) by comparing it to +0.0
	sahf							;transfer condition codes to CPU's flag register
	jz		_AddToSubtotal

	; multiply current sum by 10
	mov		floatBuffer, 10
	fild	floatBuffer
	fmul

_AddToSubtotal:
	movsx	EAX, AL
	mov		floatBuffer, EAX		
	fild	floatBuffer				
	fadd

_EndInteration:
	loop	_JumpToLoopStart

	; multiply total with sign at ST(1). (-1 or +1)
	fmul

; ------------------------------------------------------------------------
; 3. Store this one value in a memory variable (output, reference). 
;    Store in memory variable as running average
; ------------------------------------------------------------------------
	; Store final result to memory
	fld		ST(0)						;copy final result by pushing ST(0)
	mov		EAX, [EBP+8]
	fstp	REAL8 PTR [EAX]			;pop final result to array element addr

	; Add final result to running total
	mov		EAX, [EBP+20]
	fld		REAL8 PTR [EAX]
	fadd
	mov		EAX, [EBP+20]
	fstp	REAL8 PTR [EAX]

	; restore registers
	popad
	ret		16
ReadFloatVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteFloatVal
;
; Converts a REAL8 value to its ASCII string representation and displays it by
; calling mDisplayString, representing negative values with a '-' sign prefixed.
; 
; Postconditions: Requires the ReadVal procedure to print the integer number.
;
; Receives:
;		 [ebp+8]  =  REAL8 address (input, reference)
;
; returns: None.
; ---------------------------------------------------------------------------------
WriteFloatVal PROC
	LOCAL	stringBuffer[42]:BYTE, floatBuffer:REAL4, intBuffer:SDWORD, controlWord:WORD
	;local variables: [ebp-42], [ebp-46], [ebp-50], [ebp-42]
	pushad

; ------------------------------------------------------------------------
; 1. Whole Number Value
;	 Convert a numeric REAL4 value (input parameter, by value) to a
;	 truncated signed decimal value, then use WriteVal to display it.
; ------------------------------------------------------------------------
	finit

	;load low tolerance to FPU stack ( 1 * 10^-n )
	mov		floatBuffer, 1
	fild	floatBuffer
	mov		ECX, 12						;n
_ToleranceLoop:
	mov		floatBuffer, 10				;10 (must be 10!!!)
	fild	floatBuffer
	fdiv
	loop	_ToleranceLoop

	;load high tolerance to FPU stack ( 1 - low tolerance )
	fld		ST(0)
	mov		floatBuffer, 1
	fild	floatBuffer
	fsub
	fabs								;convert ST(0) to absolute value

	;set FPU's Round Control to 'Truncate'
	xor		EAX, EAX					;clear EAX
	fstcw	controlWord					;load control word
	mov		AX, controlWord
	or		AX, 0C00h					;set bits 10-11
	push	EAX							
	fldcw	[ESP]						;store control word 
	pop		EAX
	mov		controlWord, AX				;store 'truncate' command

	;get truncated value
	mov		EAX, [EBP+8]
	fld		REAL8 PTR [EAX]				;push float to FPU stack
	fist	intBuffer					;convert and store top value to integer value

; ------------------------------------------------------------------------
; 1. Convert a numeric integer value (input parameter, by value) to a 
;	 string of ASCII digits using sequential division by 10.
; ------------------------------------------------------------------------
	; initialize variables
	mov		EAX, intBuffer				;EAX - truncated float as SDWORD
	mov		ECX, 0						;ECX - character count
	mov		EDI, EBP					
	sub		EDI, SIZEOF stringBuffer	;EDI - buffer element address (init to first)

	;check if value is negative
	mov		floatBuffer, 0
	fild	floatBuffer
	fcomi	st,st(1)
	fstp	floatBuffer					;pop comparison value (0)
	jbe		_ConvertToString

	;if negative:
	neg		EAX							;make positive	
	push	EAX						
	mov		AL, '-'						;store '-' at stringBuffer[0]		
	cld									;clear Direction Flag (increments pointers)
	stosb								;store AL in address and move pointer
	pop		EAX

_ConvertToString:
	push	EDI							;preserve current address (0-index or 1-index)
	add		EDI, SIZEOF stringBuffer-1	;set address to last byte
	std									;set Direction Flag (decrement pointers)

	;convert and store ascii digits to end of string
_Conversionloop:						;(sequential division by 10)
	mov     EDX, 0						;clear EDX; precondition: EDX:EAX - Dividend
    mov     EBX, 10
    div     EBX							;Postcondition: EAX - Quotient, EDX - Remainder
	; store remainder as ascii
	push	EAX							;preserve quotient
	add		DL, '0'						;add 48d to DL to get ascii-equivalent
	mov		AL, DL
	stosb								;load element to AL and move pointer
	pop		EAX							;restore quotient
	inc		ECX							;character count +1
	; loop if: quotient > 0
	cmp		EAX, 0						
	jg		_Conversionloop

	; move string result to beginning of string
	mov		ESI, EDI					
	inc		ESI							;change destiniation to source
	pop		EDI							;restore start address (0-index or 1-index)
	cld									;clear Direction Flag (increments pointers)
	rep		movsb

; ------------------------------------------------------------------------
; 2. Decimal Values
; ------------------------------------------------------------------------
	;add decimal point to string
	mov		AL, '.'						
	stosb								;store AL in address and move pointer

	;setup counter and convert value to absolute value
	mov		ECX, 0						;counter - decimals added
	fabs								;convert ST(0) to absolute value

	;isolate fractional value by subtracting the truncated value
	fld		ST(0)						;push ST(0) to duplicate
	frndint								;truncate duplicate in ST(0)
	fsub

_DecimalLoop:
	;compare current fraction to low tolerance 
	fcomi	st,st(2)					
	jb		_StringFinished				;end if under tolerance

	;extract the decimal in the tenth's place to AL
	mov		floatBuffer, 10
	fild	floatBuffer
	fmul
	fist	intBuffer
	mov		EAX, intBuffer

_GetNextDigit:
	;get next fractional digit
	fld		ST(0)						;push ST(0) to duplicate
	frndint								;truncate duplicate in ST(0)
	fsub

	;check if the max number of decimals were added (2+ECX)
	cmp		ECX, 3
	jbe		_ToleranceCheck

	;check whether to round last digit
	mov		floatBuffer, 1
	fild	floatBuffer
	mov		floatBuffer, 5
	fild	floatbuffer
	fdiv
	fcomi	st,st(1)					;compare remainder to 0.5
	fstp	floatBuffer					;pop comparison number
	jb		_RoundLastDecimalUp
	jmp		_SetLoopToEnd

_ToleranceCheck:
	;compare next fraction to high tolerance (0.999....)
	fcomi	st,st(1)					
	jb		_AddDecimalCharacter		;continue if below tolerance

_RoundLastDecimalUp:
	;above tolerance:
	cmp		AL, 9
	je		_SetLoopToEnd
	inc		EAX							;increment EAX (simulates rounding)
_SetLoopToEnd:
	fstp	floatBuffer
	mov		floatBuffer, 0
	fild	floatBuffer					;make ST(0) = 0 to end loop

_AddDecimalCharacter:
	;convert AL to a character
	add		AL, '0'						;add 48d to DL to get ascii-equivalent
	stosb								;load element to AL and move pointer
	inc		ECX
	jmp		_DecimalLoop

; ------------------------------------------------------------------------
; 3. Invoke the mDisplayString macro to print the ASCII 
;	 representation of the REAL4 value to the output.
; ------------------------------------------------------------------------
_StringFinished:
	;add 0 to string if no fractional numbers
	cmp		ECX, 0
	jne		_NullTerminateString
	mov		AL, '0'
	stosb

_NullTerminateString:
	mov		AL, 0
	stosb

	mov		ESI, EBP					
	sub		ESI, SIZEOF stringBuffer	;ESI - stringBuffer address
	mDisplayString ESI

    ; Restore registers           
	popad
	ret     4
WriteFloatVal ENDP

; ---------------------------------------------------------------------------------
; Name: getFloatStatistics
;
; Generates the sum and truncated average of all floats in the provided array,
; storing them in memory addresses provided as a parameters for sum and average.
;
; Preconditions: Array address provided must be filled with at least 1 REAL value.
;
; Postconditions: The sum and truncated average of the input array is stored in 
;				  the memory addresses provided as parameters.
;
; Receives:
;		[ebp+20]  =  address of average (output, by reference)
;		[ebp+16]  =  address of sum (output, by reference)
;		[ebp+12]  =  address of number array (input, by reference)
;		 [ebp+8]  =  length of the number array (input, by value)
;
; returns: None.
; ---------------------------------------------------------------------------------
getFloatStatistics PROC
	LOCAL	floatBuffer:REAL4
	pushad
	finit

	;generate sum
	mov		ECX, [ebp+8]			;ECX: length of number array
	mov		ESI, [ebp+12]			;ESI: address of memory array
	mov		floatBuffer, 0			;initialize sum
	fild	floatBuffer
_SumLoop:
	fld		REAL8 PTR [ESI]
	fadd
	add		ESI, 8
	loop	_SumLoop

	;store sum
	fld		ST(0)					;copy current sum
	mov		EDI, [EBP+16]
	fstp	REAL8 PTR [EDI]			;pop current sum to floatsSum address

	;generate truncated average
	fild	DWORD PTR [ebp+8]
	fdiv							;sum divide sum by number of elements
	;store truncated average
	mov		EDI, [EBP+20]
	fstp	REAL8 PTR [EDI]			;pop current sum to floatsSum address

	popad
	ret 16
getFloatStatistics ENDP

END main
