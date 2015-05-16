; -*- tab-width: 4 -*-
; VW CD Changer Protocol Implementation 
; For use on PIC12F6XX at 4MHz/5VDC
;
; Copyright (c) 2002-2005, K9spud LLC.
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;; Please visit http://www.k9spud.com/ where you can find the latest 
;; version of this software and information on building the hardware 
;; needed to run this software.
;;
;; If you sell devices derived from this software, make sure you read
;; and strictly adhere to the provisions set forth in the GNU General Public 
;; License. Specifically, any modifications you make to this source code
;; must be made available to the public under the GNU GPL.
;;
;; Credits
;; -------
;; Andy Wilson <awilson@NOSPAM.microsoft.com> - Monsoon protocol info
;; Paul Stewart <stewart@NOSPAM.parc.com> - Monsoon debugged code
;; Svetoslav Vassilev <svetoslav.vassilev@NOSPAM.excite.com> - Double DIN fixes
;; Tony Gilbert <tony.gilbert@NOSPAM.orange.co.uk> - Blaupunkt Gamma V codes
;; Adam Yellen <adam@NOSPAM.yellen.com> - Mk3 command codes
;; Paul Burgess <pburgess@NOSPAM.babson.edu> - Audi Concert command codes
;; Hans-Dieter Wohlmuth <hans-dieter.wohlmuth@NOSPAM.infineon.com> -
;;		Suggested changes to improve Audi Concert II remote control capability.
;;
;; $Log: vwcdpic.asm,v $
;; Revision 1.62.4.8  2005/05/14 19:14:43  edwards
;; Tagged for v2.7d release.
;;
;; Revision 1.62.4.7  2005/05/10 04:45:39  edwards
;; Acknowledge bit wasn't being set correctly.
;; CD Loaded packets weren't being generated correctly.
;; Added RCD300 hold down mix button command.
;;
;; Revision 1.62.4.6  2005/05/01 21:40:45  edwards
;; Fixed a little bug with MIX light being inverted.
;;
;; Revision 1.62.4.5  2005/05/01 08:00:18  edwards
;; First attempt at inverting all head unit packet data bits so that it is easier to
;; read the source code.
;;
;; Revision 1.62.4.4  2005/05/01 04:41:37  edwards
;; Backed out previous serial fix and applied a different fix that is more correct.
;; Added support for VWCDPIC v3.x hardware layout.
;; Added support for more PICmicro chips that are compatible.
;; Started migrating Volkswagen CMR to mainline branch.
;;
;; Revision 1.62.4.3  2005/04/30 07:35:58  edwards
;; Modified timing of 19.2Kbps serial routine. Now works on PIC12F683.
;;
;; Revision 1.62.4.2  2005/04/24 06:41:36  edwards
;; Started adding support for new PIC12F683 chip. Untested right now.
;;
;; Revision 1.62.4.1  2005/04/24 05:01:24  edwards
;; Modified head unit refresh period from 100ms between refresh packets
;; down to 50ms between refresh packets. Maybe this will help with RCD300
;; head units.
;;
;; Revision 1.62  2004/07/16 01:02:03  edwards
;; Added track rollover for Audi Concert II jog wheel.
;;
;; Revision 1.61  2004/07/15 12:21:56  edwards
;; Set version strings for v2.7b.
;;
;; Revision 1.60  2004/07/15 12:12:07  edwards
;; Added SendDisplayBytesInitCD routine for loading initial CD information.
;;
;; Revision 1.59  2004/07/15 11:28:49  edwards
;; Some Archos Jukeboxes appearantly don't have their own pull-up resistor 
;; for serial remote control.
;;
;; Revision 1.58  2004/07/04 07:25:17  edwards
;; Set version strings for v2.7 release.
;;
;; Revision 1.57  2004/07/04 03:12:07  edwards
;; Remapped commands for Archos remote control.
;;
;; Revision 1.56  2004/06/30 07:36:22  edwards
;; Fixed some bugs setting up the Archos 9600 baud serial TX pin.
;;
;; Revision 1.55  2004/06/29 06:33:36  edwards
;; Added TrackLeadIn state, fixed bugs in ACK support.
;;
;; Revision 1.54  2004/06/28 06:34:25  edwards
;; Fixed some bugs and re-enabled Archos support
;;
;; Revision 1.51  2004/06/28 03:23:49  edwards
;; Implemented new state machine w/command ACK support.
;;
;; Revision 1.47  2004/06/27 08:51:43  edwards
;; First pass at new command recognition code.
;;
;; Revision 1.45  2004/06/25 03:56:33  edwards
;; documenting more protocol info
;;
;; Revision 1.46  2004/06/27 08:49:31  edwards
;; TX buffer and command RX buffer were allocated overlapping memory regions.
;;
;; Revision 1.44  2004/05/16 22:18:58  edwards
;; Fixed some bugs in disabling Archos support. Caused MIX6
;; and DN/UP for Mk3 head units to lock up the VWCDPIC firmware in an
;; endless loop.
;;
;; Revision 1.43  2004/05/02 19:20:14  edwards
;; Disabled Archos Jukebox support to see if that helps European head unit
;; problems.
;;
;; Revision 1.42  2004/01/21 04:31:16  edwards
;; Added support for compiling against PIC16F627 target.
;;
;; Revision 1.41  2004/01/19 00:17:45  edwards
;; Final cleanup for v2.6 release.
;;
;; Revision 1.40  2004/01/18 23:27:54  edwards
;; no message
;;
;; Revision 1.39  2004/01/18 20:22:23  edwards
;; Added back Archos support (still untested).
;;
;; Revision 1.38  2004/01/18 06:36:24  edwards
;; Fixed code that spits out invalid command packet bytes captured.
;;
;; Revision 1.37  2004/01/18 05:19:37  edwards
;; Finally got the string queuing code working bug free.
;;
;; Revision 1.36  2004/01/18 03:18:21  edwards
;; Fixed some bugs in the new code.
;;
;; Revision 1.35  2004/01/18 02:00:58  edwards
;; added implementation for EnqueueString
;;
;; Revision 1.34  2004/01/18 00:10:14  edwards
;; no comment
;;
;; Revision 1.33  2004/01/17 19:18:50  edwards
;; Adding support for an outbound serial string print queue.
;;
;; Revision 1.32  2004/01/13 06:41:32  edwards
;; Adding back support for recognizing commands.
;;
;; Revision 1.31  2004/01/13 05:09:04  edwards
;; no message
;;
;; Revision 1.30  2004/01/13 04:48:01  edwards
;; interim improvements to capture code.
;;
;; Revision 1.29  2004/01/12 06:58:26  edwards
;; Starting to work on reverse bit order command capture. This bit ordering
;; will make it more natural to read command bits as they were captured.
;;
;; Revision 1.28  2004/01/12 04:48:59  edwards
;; Filter seems to work, but doesn't solve the problem.
;;
;; Revision 1.27  2004/01/12 01:30:27  edwards
;; second try at improved command noise filtering
;;
;; Revision 1.26  2004/01/12 01:08:09  edwards
;; first try at improved command noise filtering
;;
;; Revision 1.25  2003/10/09 07:29:28  edwards
;; Increased delay between bytes sent to the head unit to 700us per suggestion
;; from Svet. Maybe helps with late 2003 Wolfsburg double din drop out problem.
;;
;; Revision 1.24  2003/09/28 18:55:00  edwards
;; Committed Svet's changes to cvs repository.
;; Fixed a small bug in MK3 button up/dn support.
;; Added EEPROM copyright notice.
;;
;; Revision 1.23  2003/09/17 05:40:22  edwards
;; Changed licensing to GNU GPL. Maybe we can get some more developers
;; playing with this now that it is Open Source proper.
;;
;; Revision 1.22  2003/08/17 08:39:45  edwards
;; Increased default refresh period to 10ms so that seconds can be perfectly 
;; timed.
;; Added a Wait30 to the SendByte routine to soften emi noise.
;;
;; Revision 1.21  2003/08/12 04:19:09  edwards
;; Moving VWCDPIC PIC12F629 based firmware into the mainline branch.
;;
;; Revision 1.8  2003/08/01 22:52:37  edwards
;; Do_UNKNOWNCMD now calls SendNEWLINE so that commands are properly
;; recognized by the PJRC MP3 Player. Was causing trouble on Monsoon
;; Double DIN head unit.
;;
;; Revision 1.7  2003/08/01 21:58:33  edwards
;; Removed unused serial recieve code.
;; Added support for incrementing the minutes:seconds display on Double DIN
;; head units.
;; Added support for momentarily turning on the "scan mode" display when
;; the scan button is pushed at the head unit.
;;
;; Revision 1.6  2003/07/07 17:32:26  edwards
;; Incremented version number
;;
;; Revision 1.5  2003/07/07 17:29:12  edwards
;; Changed disc load packets from 0x19..0x1F to 0x29..0x2F so that it does 
;; not say "CD-ROM" and beep on Monsoon head units. 
;;
;; Thanks goes to Svetoslav Vassilev for finding the AUDIO CD load packets.
;;
;; Revision 1.4  2003/04/26 03:18:15  edwards
;; Added code to setting the oscillator calibration register.
;;
;; Revision 1.3  2003/04/25 08:04:14  edwards
;; no comment
;;
;; Revision 1.2  2003/04/25 06:50:23  edwards
;; Made space for calibration data at end of memory.
;;
;; Revision 1.1  2003/04/25 06:48:24  edwards
;; First try at VWCDPIC 2.0 firmware.
;;
;; Revision 1.19  2003/03/08 02:34:24  edwards
;; First try at implementing Archos remote control.
;;
;; Revision 1.18  2003/03/03 14:40:58  edwards
;; At power up, we now use DISCSTART to wait before sending CD load
;; packets.
;;
;; Revision 1.17  2003/03/03 06:05:58  howard
;; Incremented version number.
;;
;; Revision 1.16  2003/03/03 06:05:18  howard
;; Now we can wait a variable number of display update packets before
;; sending the disc load packets.
;;
;; Revision 1.15  2003/03/03 05:48:15  howard
;; Going beyond CD6 is no longer allowed (should help compatibility with
;; Monsoon head units).
;;
;; Revision 1.14  2003/03/03 05:26:41  howard
;; Now recognizes MIX6 key code.
;; Recognizes Up/Dn Mk3 key codes as provided by Adam Yellen.
;;
;; Revision 1.13  2003/01/14 06:51:48  edwards
;; Documented Mix6 scan code.
;;
;; Revision 1.12  2002/12/02 00:13:44  edwards
;; Made the powered identify string display much slower now so that it won't
;; be so annoying.
;;
;; Moved the state jump table down to the end of program memory space so
;; that it is guaranteed to be page aligned.
;;
;; SendNEWLINE now sends character 13 followed by character 10 so that
;; Windows Hyperterminal will linefeed properly.
;;
;; Revision 1.11  2002/12/01 21:17:59  edwards
;; Added code to dump unknown command packets to the serial port.
;;
;; Revision 1.10  2002/12/01 20:50:39  edwards
;; My blind attempt at moving Paul Stewart's Monsoon code back into the
;; mainline firmware branch.
;;
;; Revision 1.9  2002/12/01 08:43:36  edwards
;; Formatting changes for MPLAB IDE 6.
;;
;; Revision 1.8  2002/12/01 08:25:53  edwards
;; Added project file for MPLAB IDE 6.
;;
;; v1.2
;; 	added first pass at a Monsoon state implementation, untested.
;;
;; v1.1b 
;; 	fixed SendSerialHex bugs
;;
;; v1.1
;;	removed all instances of ready-modify-write's to PORT regs
;; 	added CD[1..6] button recognition
;;	made display update send identification strings to serial
;;
;; v1.0
;;	initial release
				
; Precompiler Options

; dump all command data packets to serial port, doesn't
; try to identify them at all. useful for debugging protocol only.
;#define DUMPMODE

; Archos Jukebox 9600 baud remote control support. 
#define ARCHOS_SUPPORT

; This firmware source code file is intended to support all hardware
; revisions of the VWCDPIC device. Below are descriptions of the
; different hardware revision's pin connections to the PICmicro. 
; You must uncomment one "#define" statement to select which hardware
; revision you want to compile for.

;--------------------------------------------------------------------------
; VWCDPIC 1.x PIC16F627 Connections
;--------------------------------------------------------------------------
; PIC RA3 -> VW Pin 2 Clock  to Head Unit
; PIC RA2 -> VW Pin 1 Data   to Head Unit
; PIC RB0 <- VW Pin 4 Data from Head Unit
; Make sure PIC and VW Head Unit have common GND.
; 
; PIC RB6 -> PJRC MP3 Player RX (19.2Kbps serial, working)
; PIC RB7 -> Archos Jukebox RX (9600bps serial, untested)
; Make sure PIC and MP3 Player have common GND.
;--------------------------------------------------------------------------
;#define VWCDPIC_1X

;--------------------------------------------------------------------------
; VWCDPIC Volkswagen CMR PIC16F627(a)/PIC16F628(a) Connections
;--------------------------------------------------------------------------
; PIC RA3 -> VW Pin 2 Clock  to Head Unit
; PIC RA2 -> VW Pin 1 Data   to Head Unit
; PIC RB0 <- VW Pin 4 Data from Head Unit
; Make sure PIC and VW Head Unit have common GND.
; 
; PIC RB6 -> PJRC MP3 Player RX (19.2Kbps serial)
; PIC RB7 -> Archos Jukebox RX (9600bps serial with weak pull-up)
; Make sure PIC and MP3 Player have common GND.
;
; Volkswagen CMR:
; PIC RB1 -> TP11 when button Mix is pressed has about 15 
;			 seconds logic low output (one pulse)
;			 ALSO:
;			 when soft-button CD6 is pressed, TP11 has 
;			 about 3 seconds logic low output (one pulse)
;			 FINALLY:
;			 when button SCAN is pressed, TP11 has about 20ms
; 			 logic low output (one pulse)
;
; PIC RB2 -> TP14 when button Next Track (>>) is pressed, has 
;			 about 20ms logic low output (one pulse)
;
; PIC RB3 -> TP15 when button Last Track (<<) is pressed, TP15 
;			 has about 20ms logic low output (one pulse)
;
; PIC RB4 -> Track number is incremented when one pulse (low active) on RB4
;
; PIC RB5 -> Track number is decremented when one pulse (low active) on RB5
;--------------------------------------------------------------------------
;#define VWCDPIC_CMR

;--------------------------------------------------------------------------
; VWCDPIC 2.x PIC12F629/PIC12F675/PIC12F683 Connections
;--------------------------------------------------------------------------
; PIC GP5 -> VW Pin 2 Clock  to Head Unit
; PIC GP4 -> VW Pin 1 Data   to Head Unit
; PIC GP2 <- VW Pin 4 Data from Head Unit
; Make sure PIC and VW Head Unit have common GND.
; 
; PIC GP0 -> PJRC MP3 Player RX (19.2Kbps serial)
; PIC GP1 -> Archos Jukebox RX (9600bps serial with weak pull-up)
; Make sure PIC and MP3 Player have common GND.
;--------------------------------------------------------------------------
;#define VWCDPIC_2X

;--------------------------------------------------------------------------
; VWCDPIC 3.x PIC12F629/PIC12F675/PIC12F683 Connections
;--------------------------------------------------------------------------
; PIC GP0 -> VW Pin 2 Clock  to Head Unit
; PIC GP1 -> VW Pin 1 Data   to Head Unit
; PIC GP2 <- VW Pin 4 Data from Head Unit
; Make sure PIC and VW Head Unit have common GND.
; 
; PIC GP4 -> PJRC MP3 Player RX (19.2Kbps serial)
; PIC GP5 -> Archos Jukebox RX (9600bps serial with weak pull-up)
; Make sure PIC and MP3 Player have common GND.
;--------------------------------------------------------------------------
#define VWCDPIC_3X

;;; This code targets several different PICmicro chips, you must select
;;; which PIC you are using with the command line setting to assembler.
;;;
;;; Example (PIC12F683):
;;; mpasmwin.exe /p12F683 vwcdpic.asm

	IFDEF __12F683
	LIST P=12F683, R=DEC
	__CONFIG _BOD_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT
#include <p12f683.inc>
#define PIC12F
	ENDIF

	IFDEF __12F629
	LIST P=12F629, R=DEC
	__CONFIG _BODEN_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT
#include <p12f629.inc>
#define PIC12F
	ENDIF

	IFDEF __12F675
	LIST P=12F675, R=DEC
	__CONFIG _BODEN_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT
#include <p12f675.inc>
#define PIC12F
	ENDIF

	IFDEF __16F627
	LIST P=16F627, R=DEC
	__CONFIG _BODEN_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT
#include <p16f627.inc>
#define PIC16F
	ENDIF

	IFDEF __16F627A
	LIST P=16F627A, R=DEC
	__CONFIG _BODEN_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT
#include <p16f627a.inc>
#define PIC16F
	ENDIF

	IFDEF __16F628
	LIST P=16F628, R=DEC
	__CONFIG _BODEN_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT
#include <p16f628.inc>
#define PIC16F
	ENDIF

	IFDEF __16F628A
	LIST P=16F628A, R=DEC
	__CONFIG _BODEN_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT
#include <p16f628a.inc>
#define PIC16F
	ENDIF


	IFDEF VWCDPIC_3X
;; PIC12F6XX ;;;;;;;;;;;;
SCLK			EQU	0
SRX				EQU	1
PWTX			EQU	2

SerialTX		EQU	4
SerialTX9600	EQU	5
;;;;;;;;;;;;;;;;;;;;;;;;;
#define SPIO GPIO
#define HPIO GPIO
#define INTPORT GPIO
#define STRISIO TRISIO
#define CRCMOD 	da	0x4BB
	ENDIF

	IFDEF VWCDPIC_2X
;; PIC12F6XX ;;;;;;;;;;;;
SCLK			EQU	5
SRX				EQU	4
PWTX			EQU	2

SerialTX		EQU	0
SerialTX9600	EQU	1
;;;;;;;;;;;;;;;;;;;;;;;;;
#define SPIO GPIO
#define HPIO GPIO
#define INTPORT GPIO
#define STRISIO TRISIO
#define CRCMOD 	da	0x4BB
	ENDIF

	IFDEF VWCDPIC_1X
SCLK			EQU	3		; RA3
SRX				EQU	2		; RA2
PWTX			EQU	0		; RB0/INT

SerialTX		EQU	6		; RB6
SerialTX9600	EQU	1		; RB7 (???)

#define SPIO PORTB
#define HPIO PORTA
#define INTPORT PORTB
#define STRISIO TRISB
#define CRCMOD	da 0x775
	ENDIF

	IFDEF VWCDPIC_CMR
SCLK			EQU	3		; RA3
SRX				EQU	2		; RA2
PWTX			EQU	0		; RB0/INT

SerialTX		EQU	6		; RB6
SerialTX9600	EQU	7		; RB7 

TP11			EQU 1		; RB1/TP11
TP14			EQU	3		; RB2/TP14
TP15			EQU 2		; RB3/TP15

#define SPIO PORTB
#define HPIO PORTA
#define INTPORT PORTB
#define STRISIO TRISB
#define CRCMOD	da 0x775
	ENDIF


;; Low period of PWTX line:
;; 0: ~650us
;; 1: ~1.77ms
;; S: ~4.57ms

STARTTHRESHOLD	EQU	100			; greater than this signifies START bit
HIGHTHRESHOLD	EQU	39			; greater than this signifies 1 bit.
LOWTHRESHOLD	EQU	8			; greater than this signifies 0 bit.
PKTSIZE			EQU -32			; command packets are 32 bits long.

; do not refresh head unit faster than 5.5ms (currently not implemented)
; 5.24s slow refresh rate when head unit in FM/AM/Tape mode (not implemented)
REFRESH_PERIOD	EQU	50			; default to refresh head unit every 50.0ms
SECONDWAIT		EQU	-20			; wait 20 * 50ms to get 1 second (50ms*20 = 1000ms = 1s)
POWERIDENTWAIT	EQU -15			; wait 10 * 1s to 10 seconds between VWCDPICx.x display
SCANWAIT		EQU	-50			; wait 100 * 50ms to get 5sec (50ms*100 = 5000ms = 5s)

VER_MAJOR		EQU	'2'
VER_MINOR		EQU	'7'
VER_PATCHLEVEL	EQU	'd'

;--------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------
GPRAM			EQU 32
sendreg			EQU	GPRAM+0
sendbitcount	EQU	GPRAM+1		; Used in SendByte routine

disc			EQU	GPRAM+2
track			EQU	GPRAM+3
minute			EQU	GPRAM+4
second			EQU	GPRAM+5
		
scanptr			EQU	GPRAM+6		; pointer to command byte to inspect next
scanbyte		EQU	GPRAM+7		; most recently retrieved command byte
cmdcode			EQU	GPRAM+8		; command code received from head unit (byte 3)

; these storage bytes are for the ISR to save process state so that it
; doesn't adversely affect the main loop code. you must -not- use these
; variables for anything else, as the ISR -will- corrupt them.
intwsave		EQU	GPRAM+9
intstatussave	EQU	GPRAM+10
intfsrsave		EQU	GPRAM+11

progflags		EQU	GPRAM+12

; the 'capbusy' flag will be set when the ISR is busy capturing a command 
; packet from the head unit. The TMR0 ISR will clear it once the recieve 
; timeout has been exceeded or the PWTX capture ISR will clear it once
; 32 bits have been captured (command packets are supposed to be 32 bits
; long only).
capbusy			EQU	0

; 'mix' and 'scan' flags specify whether we want to light up the MIX light
; or SCAN display on the head unit.
mix				EQU	1
scan			EQU	2
playing			EQU 3

	IFDEF ARCHOS_SUPPORT
; GetNextStringByte will set the 'archos' flag if the byte retrieved is intended
; for 9600 baud Archos serial out.
archos			EQU 4
	ENDIF

; The ISR will set 'dataerr' flag if it detected a framing error 
; or 'overflow' if it overflowed the capture buffer queue.
overflow		EQU 5
dataerr			EQU 6

	IFDEF DUMPMODE
; The ISR will set 'startbit' flag if it detected a start bit.
startbit		EQU 7
	ENDIF

captime			EQU	GPRAM+13	; timer count of low pulse (temp)
capbit			EQU	GPRAM+14	; bits left to capture for this byte
capbitpacket	EQU	GPRAM+15	; bits left to capture for the entire packet
capptr			EQU	GPRAM+16	; pointer to packet capture buffer loc

BIDIstate		EQU	GPRAM+17	; pointer to the current state handler routine
BIDIcount		EQU	GPRAM+18	; counts how long to stay in current state
ACKcount		EQU	GPRAM+19	; number of ACK bits to set.
discload		EQU	GPRAM+20	; next disc number to load

poweridentcount	EQU	GPRAM+21	; counts down until we should send VWCDPICx.x
secondcount		EQU	GPRAM+22	; counts down until one second has passed
scancount		EQU	GPRAM+23	; used to count down displaying SCAN mode

txinptr			EQU	GPRAM+24
txoutptr		EQU	GPRAM+25
txbuffer		EQU	GPRAM+26
txbufferend		EQU	GPRAM+39	; 39-26-1 = 12 serial output strings queue
capbuffer		EQU	GPRAM+39	; 64-39-1 = 24 bytes for head unit command
capbufferend	EQU	GPRAM+64	; capture buffer (stores up to 6 commands)


;--------------------------------------------------------------------------
; Note:	4MHz / 4 = 1MHz. 1/1MHz = 1us.
;       So each PIC instruction takes one microsecond long.
;--------------------------------------------------------------------------
; Program Code
;--------------------------------------------------------------------------
	ORG	0
		clrf	HPIO				; initialize port data latches

		; turn comparator off so port can be used for regular i/o functions
		movlw   (1<<CM2)|(1<<CM1)|(1<<CM0)
	IFDEF CMCON0
		movwf   CMCON0
	ELSE
		movwf   CMCON				
	ENDIF

		goto	Start

;--------------------------------------------------------------------------
; Interrupt Service Routine
; 
; Interrupt Sources:
;	RB0/INT Used for recieving head unit button commands
;	TMR0	Used for timing head unit button command pulse width
;--------------------------------------------------------------------------
	ORG	4
	movwf	intwsave			; preserve w register
	swapf	STATUS, w			; preserve status register
	movwf	intstatussave

	movf	TMR0, w				; save a copy of current TMR0 count
	movwf	captime				; in case PWTXCaptureBit needs it

	movf	FSR, w				; preserve FSR register
	movwf	intfsrsave
	
PWTXCaptureISR:
	btfss	INTCON, INTF		; RB0/INT interrupt (PWTX Capture)?
	goto	TMR0ISR

	clrf	TMR0				; restart timer
	bcf		INTCON, INTF		; clear interrupt flag

	btfsc	INTPORT, PWTX
	goto	PWTXCaptureBit

PWTXStartTimer:
	;; We have interrupted at beginning of low pulse (falling edge)
	;; Low pulse length must be timed to determine bit value

	bcf		INTCON, T0IF		; clear TMR0 overflow flag
	bsf		INTCON, T0IE		; enable TMR0 interrupt on overflow

	bsf		STATUS, RP0			; select data bank 1
	ERRORLEVEL -302
	bsf		OPTION_REG, INTEDG	; set interrupt on rising edge
	ERRORLEVEL +302
	bcf		STATUS, RP0			; go back to data bank 0

	goto	EndInterrupt

PWTXCaptureBit:
	;; We have interrupted at beginning of high pulse (rising edge)
	;; High pulse length doesn't matter. We need to check out
	;; captured low pulse width if we are capturing data at the moment

	bsf		STATUS, RP0			; select data bank 1
	ERRORLEVEL -302
	bcf		OPTION_REG, INTEDG	; set interrupt on falling edge
	ERRORLEVEL +302
	bcf		STATUS, RP0			; go back to data bank 0

	btfss	INTCON, T0IE		; are we trying to capture data?
	goto	EndInterrupt

	bsf		progflags, capbusy
	bcf		INTCON, T0IE		; turn off capturing time for high pulse

	movlw	STARTTHRESHOLD		; is the timer counter larger than the START
	subwf	captime, w			; threshold value?
	btfss	STATUS, C
	goto	FilterNoise			; no, just a regular data bit

	IFDEF DUMPMODE
	bsf		progflags, startbit
	ENDIF

	movlw	PKTSIZE				; reset packet bit counter
	movwf	capbitpacket

	;; don't store start bits, just frame around them
	goto	StartNewByteIfNecessary

FilterNoise:
	movlw	LOWTHRESHOLD		; is the timer count less than the
	subwf	captime, w			; LOWTHRESHOLD?
	btfss	STATUS, C
	goto	EndInterrupt		; yes. invalid, probably noise induced. ignore.

	; no, go ahead and store this data	
SaveBit:
	movf	capptr, w			; load capture pointer into indirect pointer
	movwf	FSR

	movlw	HIGHTHRESHOLD		; is the timer count larger than the
	subwf	captime, w			; HIGH bit threshold value?
	rlf		INDF, f				; save captured bit into capture buffer

	incfsz	capbitpacket, f
	goto	IncrementCaptureBit

	; we've received PKTSIZE number of bits, so let's assume that we're done
	; capturing bits for now.
	bcf		progflags, capbusy	; clear capture busy flag

IncrementCaptureBit:
	incfsz	capbit, f			; have we collected all 8 bits?
	goto	EndInterrupt		; nope
	goto	StartNewByte		; yep, get ready to capture next 8 bits

TMR0ISR:
	btfss	INTCON, T0IE		; is timer 0 overflow interrupt enabled?
	goto	EndInterrupt
	btfss	INTCON, T0IF		; if so, did a timer 0 overflow occur?
	goto	EndInterrupt

	bcf		INTCON, T0IE		; disable further timer 0 interrupts
	bcf		progflags, capbusy	; set flag signifying packet capture done

StartNewByteIfNecessary:
	movlw	-8					; are we already capturing on a blank byte?
	subwf	capbit, w
	btfsc	STATUS, Z
	goto	EndInterrupt		; yes, no need to allocate a new byte.

	;; Note: This should never happen on normal head unit sending 32 bit
	;; 		 command strings with error free data.
	;;
	;; if the capture bits were not a complete 8 bits, we need to finish
	;; rotating the bits upward so that the data is nicely formatted
	bsf		progflags, dataerr

	movf	capptr, w			; load capture pointer into indirect pointer
	movwf	FSR
RotateLoop:
	bcf		STATUS, C			; rotate in 0 bit
	rlf		INDF, f
	incfsz	capbit, f			; have we finished rotating all bits up?
	goto	RotateLoop			; nope

StartNewByte:
	movlw	-8					; start capturing 8 bits
	movwf	capbit

	incf	capptr, f			; move to new capture byte

	movlw	capbufferend		; have we gone past the end of the
	subwf	capptr, w			; capture buffer?
	movlw	capbuffer			; yes, roll over to beginning
	btfsc	STATUS, Z
	movwf	capptr

	movf	capptr, w
	subwf	scanptr, w			; have we overflowed the capture queue?
	btfsc	STATUS, Z
	bsf		progflags, overflow

EndInterrupt:
	movf	intfsrsave, w		; restore indirect pointer
	movwf	FSR
	swapf	intstatussave, w	; restore STATUS register
	movwf	STATUS
	swapf	intwsave, f			; restore w register
	swapf	intwsave, w
	retfie

;--------------------------------------------------------------------------
; Main Program
;--------------------------------------------------------------------------
Start:
	IFDEF PIC16F
		movlw	01000000b		; initialize port data latches
		movwf	PORTA
	ENDIF	

	movlw	capbuffer			; initialize PWTX capture pointer and
	movwf	capptr				; indirect pointer to capture buffer
	movwf	scanptr

	movwf	FSR
	clrf	INDF				; make first cap byte clear for capturing
	movlw	-8					; read 8 bits of data per byte
	movwf	capbit		

	movlw	txbuffer			; initialize outgoing serial string
	movwf	txinptr				; queue pointers
	movwf	txoutptr
	
	bsf		STATUS, RP0			; select data bank 1
	ERRORLEVEL -302
	IFDEF PIC12F
		; enable GPIO pull ups
		; interrupt on rising edge
		; prescaler 1:32
		movlw	(1<<INTEDG) | (1<<PS2)	
	ELSE
		; disable all port b pull ups
		; interrupt on rising edge
		; prescaler 1:32
		movlw	(1<<NOT_RBPU) | (1<<INTEDG) | (1<<PS2)	
	ENDIF
		movwf	OPTION_REG

		;; PIC12FXXX weak pullups are enabled by default for all pins at POR.

	IFDEF PIC12F
		movlw	(1<<PWTX) | (1<<3) | (1<<SerialTX9600)
		movwf	TRISIO			; PWTX, MCLR, and SerialTX9600 pins as input
	ELSE
		movlw	(1<<PWTX) | (1<<SerialTX9600)
		movwf	TRISB			; PWTX & SerialTX9600 pins as input
		clrf	TRISA			; all others as output
	ENDIF

		clrwdt					; clear WDT & prescaler (avoids possible reset)
		
	IFDEF ANSEL
		clrf	ANSEL			; disable analog inputs
	ENDIF

	IFDEF OSCCAL
		call	3FFh			; get the calibration value
		movwf	OSCCAL			; set the calibration register
	ENDIF
	ERRORLEVEL +302
	bcf		STATUS, RP0			; go back to data bank 0
		call	SerialInit

		clrf	progflags
		clrf	ACKcount
		movlw	0x41
		movwf	disc
		movlw	0x01
		movwf	track

		movlw	POWERIDENTWAIT
		movwf	poweridentcount

		call	ResetTime
		call	SetStateIdleThenPlay

		movlw 	(1<<INTE) | (1<<GIE)
		movwf	INTCON
;;	bcf		INTCON, INTF		; clear RB0/INT interrupt flag
;;	bsf		INTCON, INTE		; enable interrupt on RB0 rising edge
;;	bsf		INTCON, GIE			; Global Interrupt Enable

		call	EnqueueIDENTIFYNEWLINE

		movlw	low sRING
		call	EnqueueString
		movlw	low sNEWLINE
		call	EnqueueString

		;; force first display update packet
SendDisplayPacket:
		; Reload the registers associated with TIMER1 so that we will
		; get a flag for the next display update packet send within
		; REFRESH_PERIOD time.
		; (1 timer clock/8uS)(1000uS/1ms) = 125 timer clocks/ms
		bcf		T1CON, TMR1ON 	; turn off timer while reloading wait period
		movlw	high (0xFFFF - (REFRESH_PERIOD * (1000 / 8)))
		movwf	TMR1H
		movlw	low (0xFFFF - (REFRESH_PERIOD * (1000 / 8)))
		movwf	TMR1L
		bcf		PIR1, TMR1IF	; clear old overflow (if any)
		movlw	00110001b		; 1:8 prescale, internal clock, tmr1 enabled.
		movwf	T1CON
							
		call	SendPacket
	
		incfsz	scancount, f
		goto	SecondWait

		movlw	SCANWAIT
		movwf	scancount
	
		movlw	~(1<<scan)			; turn off scan display
		andwf	progflags, f

SecondWait:
		incfsz	secondcount, f
		goto	IdleLoopSkipSend

		incfsz	poweridentcount, f
		goto	SecondIncrement

		call	EnqueueIDENTIFYNEWLINE
		movlw	POWERIDENTWAIT
		movwf	poweridentcount

SecondIncrement:
		movlw	SECONDWAIT
		movwf	secondcount
	
		; increment the time display
		incf	second, f

		movlw	0x0F				; skip past hexidecimal codes
		andwf	second, w
		sublw	0x0A
		movlw	6
		btfsc	STATUS, Z			; are with at xA?
		addwf	second, f			; yes, add 6 and we'll be at x0 instead
		
		movlw	0x60				; have we gone beyond 59 seconds?
		subwf	second, w
		btfss	STATUS, C
		goto	IdleLoopSkipSend

		clrf	second				; yes, set back to second 00

MinuteIncrement:
		incf	minute, f

		movlw	0x0F				; skip past hexidecimal codes
		andwf	minute, w
		sublw	0x0A
		movlw	6
		btfsc	STATUS, Z			; are with at xA?
		addwf	minute, f			; yes, add 6 and we'll be at x0 instead
	
		movlw	0xA0				; have we gone beyond 99 minutes?
		subwf	minute, w
		btfss	STATUS, C
		goto	IdleLoopSkipSend

		clrf	minute				; yes, set back to 00

IdleLoop:
	btfsc	PIR1, TMR1IF		; has REFRESH_PERIOD time passed?
	goto	SendDisplayPacket	; yes, send display packet

IdleLoopSkipSend:
	btfss	progflags, overflow	; has the command receive code detected
	goto	CheckFrameError		; an overflow error?

	bcf		progflags, overflow	; clear error flag

	movlw	low sOVERFLOW
	call	EnqueueString
	call	EnqueueNEWLINE

CheckFrameError:
	btfss	progflags, dataerr	; has the command receive code detected
	goto	NoDataError			; a framing type data error?

	bcf		progflags, dataerr	; clear error flag

	movlw	low sDATAERR
	call	EnqueueString
	call	EnqueueNEWLINE

NoDataError:
	IFNDEF DUMPMODE
		call	ScanCommandBytes
	ELSE
		btfss	progflags, startbit ; have we just recieved a start bit?
		goto	DumpLoop

		bcf		progflags, startbit ; yes, start a new line
		call	EnqueueNEWLINE

DumpLoop:
		call	GetCaptureByte	; do we have data to dump?
		btfsc	STATUS, Z
		goto	IdleLoop		; no, exit dump loop
		movf	scanbyte, w		; yes, dump it.
		call	EnqueueHex
		goto	DumpLoop
	ENDIF

SendTXStringByte:
	movf	txoutptr, w
	movwf	FSR

	subwf	txinptr, w			; has the TX buffer consumer caught
	btfsc	STATUS, Z			; up with the TX producer?
	goto	IdleLoop			; yes, nothing to send out serial port for now

	call	GetNextStringByte
	btfsc	STATUS, Z			; did we reach the end of the current string?
	goto	SendTXStringByte	; yes, try send byte from next string.

	call	SerialLoad			; put w into serial sendreg and init sendbitcount

	;; TODO add code to see if we've got TMR0 < x signifying we have
	;; enough time to send one byte of data without danger of head unit
	;; command capture data corruption.
		
	btfsc	progflags, capbusy
	goto	IdleLoop			; it may not be safe to mask interrupts 
								; right now, so abort sending this byte until 
								; later when it becomes safe.
DoSend:
	IFDEF ARCHOS_SUPPORT
		btfss	progflags, archos	; are we trying to send an archos command?
		goto	Send19200

SendArchos:
		call	SerialSend9600
		bcf		progflags, archos	; turn off archos flag for next time
		call	EndString			; move to next string in queue
		goto	IdleLoop
	ENDIF

Send19200:
		call	SerialSend
		incf	INDF, f				; move to next character in string
		goto	IdleLoop

;--------------------------------------------------------------------------
; ScanCommandBytes - Looks in the command receive buffer and tries
;	to identify valid command codes.
;--------------------------------------------------------------------------
ScanCommandBytes:
		movf	scanptr, w		; set FSR register as pointer to command data
		movwf	FSR				; that we need to scan.
	
FirstByteLoop:
		call	GetCaptureByte
		btfsc	STATUS, Z
		return

FirstByteTest:
		movlw	0x53			; verify that byte 1 is 0x53
		subwf	scanbyte, w
		btfsc	STATUS, Z
		goto	SecondByte

		;; this byte doesn't match the beginning of a normal command packet,
		;; dump it for display and slide window to next byte.
		movf	scanbyte, w
		call	EnqueueHex
		call	SaveScanPointer	; save scanptr, won't look at this byte again.
		goto	FirstByteLoop
	
SecondByte:
		call	GetCaptureByte
		btfsc	STATUS, Z
		return

		movlw	0x2C			; verify that byte 2 is 0x2C
		subwf	scanbyte, w
		btfsc	STATUS, Z
		goto	ThirdByte

		;; the first byte was a match, but the second byte failed.
		;; dump first byte and then see if this one is the real first byte.
		movlw	0x53
		call	EnqueueHex
		goto	FirstByteTest

ThirdByte:
		call	GetCaptureByte
		btfsc	STATUS, Z
		return
		movf	scanbyte, w
		movwf	cmdcode			; save command code for later use.

FourthByte:
		call	GetCaptureByte
		btfsc	STATUS, Z
		return
		movf	scanbyte, w

		;; if execution reaches here, we have already verified that 
		;; bytes 1 and 2 are valid for a command packet.

		;; verify that (Byte 3 + Byte 4) = 0xFF
		addwf	cmdcode, w	
		addlw	1
		btfss	STATUS, Z
		goto	DumpFullCommand	; ABORT: dump invalid packet for display

		;; verify that Byte 3 is a multiple of 4
		movf	cmdcode, w
		andlw	00000011b
		btfss	STATUS, Z
		goto	DumpFullCommand	; ABORT: dump invalid packet for display

		call	SaveScanPointer
		movlw	-4
		movwf	ACKcount		; acknowledge command
		
		;; Now, let's jump to the section of code that handles the
		;; command we just received.
		movlw	HIGH CommandVectorTable
		movwf	PCLATH

		bcf		STATUS, C
		rrf		cmdcode, f		; cmdcode divide by 4 and save result in wreg
		rrf		cmdcode, w
		rlf		cmdcode, f		; set cmdcode back to original value
	
		addlw	low CommandVectorTable
		movwf	PCL				; jump to command handler
		;; execution should never reach here, movwf above jumps to
		;; CommandVectorTable jump table and returns from there.

DumpFullCommand:
		movf	scanptr, w		; restart back at the beginning of the packet
		movwf	FSR

		call	GetCaptureByte	; send byte 1
		btfsc	STATUS, Z
		return
		movf	scanbyte, w
		call	EnqueueHex

		call	GetCaptureByte	; send byte 2
		btfsc	STATUS, Z
		return
		movf	scanbyte, w
		call	EnqueueHex

		call	GetCaptureByte	; send byte 3
		btfsc	STATUS, Z
		return
		movf	scanbyte, w
		call	EnqueueHex
	
		call	GetCaptureByte	; send byte 4
		btfsc	STATUS, Z
		return
		movf	scanbyte, w
		call	EnqueueHex

		call	EnqueueNEWLINE
		
SaveScanPointer:
		movf	FSR, w			; save new scanptr
		movwf	scanptr
		return

Do_UNKNOWNCMD:
		;; if execution reaches here, we have verified that we got
		;; a valid command packet, but the command code received is not
		;; one that we understand.
		;; 
		;; Dump the unknown command code for the user to view.	
		movlw	low sDASH
		call	EnqueueString

		movf	cmdcode, w
		call	EnqueueHex

		movlw	low sDASH
		call	EnqueueString
		
		goto	EnqueueNEWLINE		


;--------------------------------------------------------------------------
; Button Push Packets
;--------------------------------------------------------------------------
; 532C609F Mix 1
; 532CE01F Mix 6
; 532CA05F Scan
;	  Note: Blaupunkt Gamma V head unit will continue to send scan key code
;		unless display is switched into scan mode. 
;		(reported by tony.gilbert@orange.co.uk)
; 532C10EF Head Unit mode change. Emitted at power up, power down, and
;		 any mode change. (disable playing)
; 532C58A7 Seek Back Pressed
; 532CD827 Seek Forward Pressed
; 532C7887 Dn
; 532CA857 Dn on Mk3 premium (Adam Yellen <adam@yellen.com>)
; 532CF807 Up
; 532C6897 Up on Mk3 premium (Adam Yellen)
; 532C38C7 CD Change (third packet)
; 532CE41B Seek Forward Released (enable playing)
; 532CE41B Seek Back Released (enable playing)
; 532CE41B CD Mode selected. Emitted at power up (if starting in CD 
;			 mode), change to CD mode. (enable playing)
; 532C14EB CD Change (second packet)
; 532C0CF3 CD 1 (first packet)
; 532C8C73 CD 2 (first packet)
; 532C4CB3 CD 3 (first packet)
; 532CCC33 CD 4 (first packet)
; 532C2CD3 CD 5 (first packet)
; 532CAC53 CD 6 (first packet)
;
; Monsoon State Changes:
; 532CE41B enable playing (transition to State 2)
; 532C38C7 disc loaded inquiry (transition to State 5)
; 532C10EF disable playing (transition to State 1)
;--------------------------------------------------------------------------

Do_CHANGECD:
		;; Head unit seems to send this after each CDx number change
		;; but the CD Changer seems to completely ignore (doesn't even ACK it).
		clrf	ACKcount		; do not ack this command
		return					

Do_ENABLE:
		btfss	progflags, playing
		call	SetStateInitPlay ; skip this if already playing

	IFDEF ARCHOS_SUPPORT
		movlw	low archosMENABLE
		call	EnqueueString
	ENDIF

		movlw	low sMENABLE
		call	EnqueueString
		goto	EnqueueNEWLINE
		
Do_LOADCD:		
		btfsc	progflags, playing
		call	SetStateInitPlay ; skip this if we're in idle mode
		call	ResetTime
		
		movlw	low sMINQUIRY
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_DISABLE:		
		btfsc	progflags, playing
		call	SetStateIdle	; skip this if we're already in idle mode

		movlw	0x41
		movwf	disc			; set back to CD 1

	IFDEF ARCHOS_SUPPORT
		movlw	low archosMDISABLE
		call	EnqueueString
	ENDIF
	
		movlw	low sMDIS
		call	EnqueueString
		movlw	low sABLE
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_SEEKBACK:
Do_PREVCD:		
		call	ResetTime

		decf	disc, f

		movlw	0x0F
		andwf	disc, w		
		btfsc	STATUS, Z		; are we at CD 0?
		incf	disc, f			; yes, set back to CD 1

	IFDEF ARCHOS_SUPPORT
		movlw	low archosSTOP
		call	EnqueueString
	ENDIF

		movlw	low sPRV
		call	EnqueueString
		movlw	low s_LIST
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_SEEKFORWARD:
		call	ResetTime
		incf	disc, f

		movlw	0x46			; have we gone above CD 6?
		subwf	disc, w
		movlw	0x46
		btfsc	STATUS, C
		movwf	disc			; yes, set back to CD 6
		; Going beyond CD9 displays hex codes on premium head unit.
		; Examples: "CD A"
		;			"CD B"
		;			"CD C" etc...
	  	;
	 	; However, going beyond CD6 mutes audio on monsoon head unit, so we 
		; definitely don't want to do that.

	IFDEF ARCHOS_SUPPORT
		movlw	low archosPLAY
		call	EnqueueString
	ENDIF

		movlw	low sNXT_LIST
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_MIX:	
		movlw	1<<mix			; toggle mix display
		xorwf	progflags, f

	IFDEF ARCHOS_SUPPORT
		movlw	low archosSHUFFLE
		call	EnqueueString
	ENDIF

		movlw	low sRANDOM
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_PLAY:
	IFDEF ARCHOS_SUPPORT
		movlw	low archosMENU
		call	EnqueueString
	ENDIF

		movlw	low sPLAY			; this will make the PJRC play/pause
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_SCAN:
		movlw	1<<scan			; toggle scan display
		xorwf	progflags, f
		movlw	SCANWAIT
		movwf	scancount

	IFDEF ARCHOS_SUPPORT
		movlw	low archosMENU
		call	EnqueueString
	ENDIF

		movlw	low sPLAY			; this will make the PJRC play/pause
		call	EnqueueString
		goto	EnqueueNEWLINE
	
Do_UP:
		btfsc	progflags, playing ; skip track lead-in if not in play mode
		call	SetStateTrackLeadIn
		
		call	ResetTime

		incf	track, f
		
		movlw	0x0F			; skip past hexidecimal codes
		andwf	track, w
		sublw	0x0A
		movlw	6
		btfsc	STATUS, Z		; are with at xA?
		addwf	track, f		; yes, add 6 and we'll be at x0 instead
	
		movlw	0xA0			; have we gone beyond Track 99?
		subwf	track, w
		movlw	0x01
		btfsc	STATUS, C
		movwf	track			; yes, rollover to Track 01 so that jog wheels
								; can continue rolling (Audi Concert II)

	IFDEF ARCHOS_SUPPORT
		movlw	low archosNEXT
		call	EnqueueString
	ENDIF

		movlw	low sNEXT
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_DOWN:
		btfsc	progflags, playing ; skip track lead-in if not in play mode
		call	SetStateTrackLeadIn
		
		call	ResetTime

		; skip past hexidecimal track numbers
		movlw	0x0F
		andwf	track, w		
		movlw	0x06
		btfsc	STATUS, Z		; are we at x0?
		subwf	track, f		; yes, subtract 6 and we'll be at x9 instead

		decf	track, f
		movlw	0x99
		btfsc	STATUS, Z		; have we gone below Track 1?
		movwf	track			; yes, rollover to Track 99 so that jog wheels
								; can continue rolling (Audi Concert II)

	IFDEF ARCHOS_SUPPORT
		movlw	low archosPREVIOUS
		call	EnqueueString
	ENDIF

		movlw	low sPREVIOUS
		call	EnqueueString
		goto	EnqueueNEWLINE

Do_CD1:
	movlw	0x41
	movwf	disc			; set CD 1

	IFDEF ARCHOS_SUPPORT
		movlw	low archosLIST1
		call	EnqueueString
	ENDIF

	call	EnqueueLIST
	movlw	low s1
	call	EnqueueString
	goto	EnqueueNEWLINE

Do_CD2:
	movlw	0x42
	movwf	disc			; set CD 2

	IFDEF ARCHOS_SUPPORT
		movlw	low archosLIST2
		call	EnqueueString
	ENDIF

	call	EnqueueLIST
	movlw	low s2
	call	EnqueueString
	goto	EnqueueNEWLINE

Do_CD3:
	movlw	0x43
	movwf	disc			; set CD 3

	IFDEF ARCHOS_SUPPORT
		movlw	low archosLIST3
		call	EnqueueString
	ENDIF

	call	EnqueueLIST
	movlw	low s3
	call	EnqueueString
	goto	EnqueueNEWLINE

Do_CD4:
	movlw	0x44
	movwf	disc			; set CD 4

	IFDEF ARCHOS_SUPPORT
		movlw	low archosLIST3
		call	EnqueueString
	ENDIF

	call	EnqueueLIST
	movlw	low s4
	call	EnqueueString
	goto	EnqueueNEWLINE

Do_CD5:
	movlw	0x45
	movwf	disc			; set CD 5

	IFDEF ARCHOS_SUPPORT
		movlw	low archosLIST3
		call	EnqueueString
	ENDIF

	call	EnqueueLIST
	movlw	low s5
	call	EnqueueString
	goto	EnqueueNEWLINE

Do_CD6:
	movlw	0x46
	movwf	disc			; set CD 6

	IFDEF ARCHOS_SUPPORT
		movlw	low archosLIST3
		call	EnqueueString
	ENDIF

	call	EnqueueLIST
	movlw	low s6
	call	EnqueueString
	goto	EnqueueNEWLINE

;--------------------------------------------------------------------------
; GetCaptureByte
; Returns: STATUS Z bit set - no more bytes to collect
; 	   STATUS Z bit clear - scanbyte contains next byte, FSR inc'd
;--------------------------------------------------------------------------
GetCaptureByte:
	movf	FSR, w			; have we already caught up with capturer?
	subwf	capptr, w
	btfsc	STATUS, Z
	return

	movf	INDF, w			; get a byte from the capture buffer
	movwf	scanbyte

	incf	FSR, 1
	movlw	capbufferend	; have we overflowed the 
	subwf	FSR, w			; capture buffer?
	btfss	STATUS, Z
	return

	movlw	capbuffer		; yes, roll over to beginning
	movwf	FSR		
	bcf		STATUS, Z
	return			

;-----------------------------------------------------
; Display Update Packets
;-----------------------------------------------------

;;; Idle State
;;; 74 BE FE FF FF FF 8F 7C
;;; 74 BE FE FF FF FF 8F 7C
;;; ...
SetStateIdle:
		bcf		progflags, playing

		movlw	low StateIdle
		movwf	BIDIstate
		return

;;; Real CD Changer doesn't really do this, but we're gonna do it to try
;;; and make sure we unmute the audio even if the user didn't connect
;;; the PW-TX pin properly.
SetStateIdleThenPlay:
		bcf		progflags, playing

		movlw	low StateIdleThenPlay
		movwf	BIDIstate

		movlw	-20
		movwf	BIDIcount
		return

SetStatePlay:
		bsf		progflags, playing

		movlw	low StatePlay
		movwf	BIDIstate
		return		

;;; Initiate Playing
SetStateInitPlay:
		bsf		progflags, playing
		
		movlw	low	StateInitPlay
		movwf	BIDIstate

		movlw	0xD1
		movwf	discload
		
		movlw	-24
		movwf	BIDIcount
		return

;;; 34 BE FE FF FF FF AE 3C (play lead-in)
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
SetStatePlayLeadIn:
		bsf		progflags, playing

		movlw	low StatePlayLeadIn
		movwf	BIDIstate

		movlw	-10
		movwf	BIDIcount
		return

;;; 34BEFEFFEEFFCF3C (playing)
;;;n34BEFEFFEEFFCF3C
;;; 14BEFDFFFFFFCF1C (ack)
;;; 14BEFDFFFFFFAE1C (track lead in)
;;; 14BEFDFFFFFFAE1C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFAE3C
;;; 34BEFDFFFFFFCF3C (playing)
;;; 34BEFDFFFFFFCF3C
SetStateTrackLeadIn:
		bsf		progflags, playing

		movlw	low StateTrackLeadIn
		movwf	BIDIstate

		movlw	-12
		movwf	BIDIcount
		return					

;;; TODO: We might implement one more state machine for
;;; the CHANGECD/INQUIRY command. (mute byte goes 0x6F and 0xFF cd load
;;; while changer is busy motoring next CD into position). Then
;;; again, maybe we don't need to implement any busy states since
;;; we are instantly ready (no motoring here!).
		
ResetTime:
		movlw	SECONDWAIT
		movwf	secondcount
		clrf 	second
		clrf	minute
		return

;;; =========================================================================
;;; SEND DISPLAY UPDATE PACKETS		
;;; =========================================================================
SendPacket:
		movlw	HIGH StateVectors
		movwf	PCLATH
		movf	BIDIstate, w
		movwf	PCL			
		;; execution should not reach here, above movwf PCL jumps to
		;; state handler code.
		
SendDisplayBytes:
		movf	disc, w		; disc display value
		call	SendByte

SendDisplayBytesNoCD:	
		movf	track, w
		call	SendByte
		movf	minute, w	
		call	SendByte
		movf	second, w
		call	SendByte

; D4 - scan on, mix on
; D0 - scan on, mix off
; 04 - scan off, mix on
; 00 - scan off, mix off
		movlw	0			; mode (scan/mix)
		btfsc	progflags, mix
		iorlw	0x04		; turn on mix light

		btfsc	progflags, scan
		iorlw	0xD0		; turn on scan display

		goto	SendByte

;;; When sending an "init cd" packet, we need to send it the number of
;;; tracks and whatnot available on the CD. Required on Audi Concert II so
;;; that track up/dn buttons work.
SendDisplayBytesInitCD:	
		movlw	0x99			; number of tracks total (99)?
		call	SendByte

		movlw	0x99			; total minutes?
		call	SendByte

		movlw	0x59			; total seconds?
		call	SendByte

		movlw	0x48			; 48, 53, 31, 25, and 37 seen from real CDC, 
								; no idea what it really means.
		goto	SendByte
		
;--------------------------------------------------------------------------
; SendFrameByte - sends a framing byte to head unit (first and last bytes).
;            load byte to send to head unit into W register before calling
; If the ACK flag is set, we modify the send byte to send an
; acknowledgement.
;--------------------------------------------------------------------------
SendFrameByte:
		movf	ACKcount, f
		btfsc	STATUS, Z
		goto	SendByte

		iorlw	00100000b		; flag acknowledgement

		incf	ACKcount, f

		;; fall through to SendByte routine
		
;--------------------------------------------------------------------------
; SendByte - sends a byte to head unit.
;            load byte to send to head unit into W register before calling
;--------------------------------------------------------------------------
SendByte:
		call	SerialLoad
		incf	sendbitcount, f	; this loop needs -8 rather than -9

		;; Hopefully we don't need to disable interrupts here... Head unit
		;; seems pretty forgiving on the timing of display packet data.

		movf	HPIO, w
BitLoop:
		iorlw	(1<<SCLK)		; SCLK high
		movwf	HPIO

		andlw   ~(1<<SRX)		; load the next bit onto SRX
		rlf		sendreg, 1		; load the next bit into the carry flag
		btfss	STATUS, C
		iorlw	(1<<SRX)
		movwf	HPIO

		andlw	~(1<<SCLK)		; SCLK low

		movwf	HPIO
		call	Wait15			; timing delay to soften emi noise.
		call	Wait15

		incfsz	sendbitcount, f	; exit loop if we've transferred 8 bits already
		goto	BitLoop

;		bsf		INTCON, GIE		; re-enable interrupts
	
		;; wait for head unit to store sent byte
		;; 335us didn't work so good on late 2003 wolfsburg double din, 
		;; so we now wait 700us instead.
;		movlw	-84
		movlw	-175			; wait 700us for head unit to store sent byte
DelayLoop:				
		addlw	1				; 1
		btfss	STATUS, Z		; 1
		goto	DelayLoop		; 2

		return

;--------------------------------------------------------------------------
; SerialLoad - initializes sendreg and sendbitcount for subsequent send
;	Place byte to transmit into W register before calling.
;--------------------------------------------------------------------------
SerialLoad:
	movwf	sendreg
	movlw	-9					; send 8 bits
	movwf	sendbitcount
	return

SerialInit:
	bsf	SPIO, SerialTX
	return

;--------------------------------------------------------------------------
; SerialSend - Sends 19.2Kbps 8 bit serial data using bit banging.
;	Interrupts will be disabled for roughly 521us by this routine.
;	Interrupts will be enabled before returning.
;--------------------------------------------------------------------------
SerialSend:
	bcf		INTCON, GIE		; disable interrupts, timing critical code

	movf	SPIO, w

;; Number of clock cycles (at 1us per clock) for 19.2Kbps serial send:
;; 56us too slow, garbage
;; 54us works
;; 52us works - recommended setting
;; 50us works
;; 48us too fast, garbage

	; initially send start bit
LowBit:
	andlw	~(1<<SerialTX)  ; 1
	movwf	SPIO			; 1
	call	Wait22
	call	Wait21

BitCount:
	incf	sendbitcount, f ; 1
	btfsc	STATUS, Z		; 1 2 exit loop if we've transferred 8 bits already
	goto    StopBit			; 2

	rrf		sendreg, 1		; 1 load next bit into carry flag
	btfss	STATUS, C       ; 1 2
	goto	LowBit          ; 2

	iorlw	(1<<SerialTX)
	nop
	movwf	SPIO			; 1
	call	Wait21
	call	Wait20
	goto    BitCount        ; 2

StopBit:
	goto    $+1				; 2
	iorlw	(1<<SerialTX)
	movwf	SPIO
	bsf		INTCON, GIE		; enable interrupts, timing critical code done
	call	Wait22
	call	Wait22
	return


;--------------------------------------------------------------------------
; SerialSend9600 - Sends 9600bps 8 bit serial data using open drain bit 
; banging
;	Interrupts will be disabled for roughly 1042us by this routine.
;	Interrupts will be enabled before returning.
;--------------------------------------------------------------------------
	IFDEF ARCHOS_SUPPORT
SerialSend9600:
		bcf		SPIO, SerialTX9600 ; not quite sure why this is needed...
		
		bcf		INTCON, GIE	; disable interrupts, timing critical code
		
		;; initially send start bit
LowBit9600:
		bsf		STATUS, RP0	; select data bank 1
	ERRORLEVEL -302
		bcf		STRISIO, SerialTX9600 ; set pin as output/drain (low)
	ERRORLEVEL +302
		bcf		STATUS, RP0			; go back to data bank 0
		call	Wait23
		call	Wait23
		call	Wait23
		call	Wait23
		goto	$+1				; 94	

BitCount9600:
		incf	sendbitcount, f ; 1
		btfsc	STATUS, Z		; 1 2 exit loop if we've sent 8 bits already
		goto    StopBit9600		; 2

		rrf		sendreg, 1		; 1 load next bit into carry flag
		btfss	STATUS, C       ; 1 2
		goto	LowBit9600		; 2

		bsf		STATUS, RP0			; select data bank 1
	ERRORLEVEL -302
		bsf		STRISIO, SerialTX9600 ; set pin as input/open collector (high)
	ERRORLEVEL +302
		bcf		STATUS, RP0			; go back to data bank 0
		call	Wait23
		call	Wait23
		call	Wait23
		call	Wait23
		nop						
		goto    BitCount9600    ; 2

StopBit9600:
		nop
		nop
		bsf		STATUS, RP0		; select data bank 1
	ERRORLEVEL -302
		bsf		STRISIO, SerialTX9600 ; set pin as input/open collector (high)
	ERRORLEVEL +302
		bcf		STATUS, RP0		; go back to data bank 0
		bsf		INTCON, GIE		; enable interrupts, timing critical code done
		call	Wait24
		call	Wait24
		call	Wait24
		call	Wait24			; 96

		return
	ENDIF
		
;; --------------------------------------------------------------
EndString:
	incf	txoutptr, f		; move to next serial string in TX buffer
	movlw	txbufferend		; have we gone past the end of the
	subwf	txoutptr, w		; tx serial string buffer?
	movlw	txbuffer		
	btfsc	STATUS, Z
	movwf	txoutptr		; yes, roll over to beginning

	bsf		STATUS, Z		; flag that we don't want to send
	return

EnqueueNEWLINE:
	movlw	low sNEWLINE
	goto	EnqueueString

EnqueueIDENTIFYNEWLINE:
	movlw	low sIDENTIFYNEWLINE
	goto	EnqueueString

EnqueueLIST:
	movlw	low sLIST
	; fall through to EnqueueString routine

;--------------------------------------------------------------------------
; EnqueueString - Adds a new string pointer into the outgoing serial string
; queue.
;
; Always returns with the STATUS Z bit cleared. 
; sendbitcount value will be corrupted.
; sendreg value will be corrupted. 
;--------------------------------------------------------------------------
EnqueueString:
	movwf	sendreg				; save string pointer for a little while
	movf	FSR, w				; save FSR register for a little while
	movwf	sendbitcount
		
	movf	txinptr, w			; find out where to save the next string ptr
	movwf	FSR

	movf	sendreg, w
	movwf	INDF				; put new string ptr in serial output queue

	incf	txinptr, f			; move to next byte in queue for next time
	movlw	txbufferend			; have we gone past the end of the buffer?
	subwf	txinptr, w
	movlw	txbuffer
	btfsc	STATUS, Z
	movwf	txinptr				; yes, roll over to the beginning
		
	movf	sendbitcount, w		; restore FSR register
	movwf	FSR

	bsf		STATUS, Z
	return

;--------------------------------------------------------------------------
; EnqueueHex - Enqueues byte provided in the W register.
;	The byte is converted to a two byte ASCII hexidecimal string
;--------------------------------------------------------------------------
EnqueueHex:
	movwf	cmdcode
	swapf	cmdcode, w		; send high nibble first
	andlw	0x0F
	movwf	sendbitcount
	addwf	sendbitcount, w ; multiply W by 2.

	addlw	low s0
	call	EnqueueString

	rlf		cmdcode, f	; multiply low nibble by 2.
	movf	cmdcode, w	; now send low nibble
	andlw	(0x0F << 1)		; mask off high nibble and garbage bit

	addlw	low s0
	goto	EnqueueString

;--------------------------------------------------------------------------
; GetNextStringByte - Retrieves the next string byte from the current 
; string pointer at INDF.
;
; returns string byte in w register or sets Z flag if end of string.
;--------------------------------------------------------------------------
GetNextStringByte:
		movlw	high SerialDataStrings
		movwf	PCLATH

		movf	INDF, w
		bcf		STATUS, Z			; don't flag end of string yet
		movwf	PCL
		;; execution should never reach here, movwf above jumps to
		;; SerialDataStrings jump table and retlw's a value.

;--------------------------------------------------------------------------
; WaitXX - Burns cpu cycles for timing purposes. XX = number of cycles
;--------------------------------------------------------------------------
Wait15:	nop
		goto	Wait12

Wait21:	nop
		goto	Wait18

Wait23:	nop
		goto	Wait20

Wait24:	goto    $+1				; 24
Wait22:	goto    $+1				; 22
Wait20:	goto    $+1				; 20
Wait18:	goto    $+1				; 18
Wait16:	goto    $+1				; 16
Wait14:	goto    $+1				; 14
Wait12:	goto    $+1				; 12
Wait10:	goto    $+1				; 10
Wait8:	goto    $+1				; 8
Wait6:	goto    $+1				; 6
		return					; 4 (initial call used 2)

;;; =========================================================================
;;; WARNING:	StateVectors must not cross a 256 byte memory boundary or
;;;				firmware will crash!
;;; =========================================================================
	IF ($ < 0x200)
		ORG		0x200			; keep us within the second to last 256 page.
	ENDIF
;;; =========================================================================

StateVectors:	
StateIdle:		
		movlw	SECONDWAIT
		movwf	secondcount		; stop display from ticking time
		
		movlw	0x8B
		call	SendFrameByte
		call	SendDisplayBytes
		movlw	0x70			; mutes audio on Monsoon head units
		call	SendByte
		movlw	0x83
		goto	SendFrameByte

StateIdleThenPlay:		
		incfsz	BIDIcount, f
		goto	StateIdle
		call	SetStateInitPlay
		goto	StateIdle

;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF EF 3C
;;; 34 2D EB BE AB AC FF 3C
;;; 34 BE FE FF FF FF EF 3C
;;; 34 2C EC CE AA CE FF 3C
;;; 34 BE FE FF FF FF EF 3C
;;; 34 2B EE EE B7 DA FF 3C
;;; 34 BE FE FF FF FF EF 3C
;;; 34 2A EB BE A6 C8 FF 3C
;;; 34 BE FE FF FF FF EF 3C
;;; 34 69 00 FF FF FF FF 3C
;;; 34 BE FE FF FF FF EF 3C
StateInitPlay:
		movlw	SECONDWAIT
		movwf	secondcount		; stop display from ticking time

		movlw	0xCB
		call	SendFrameByte

		btfss	BIDIcount, 0
		goto	StateInitPlayAnnounceCD

		call	SendDisplayBytes

		movlw	0x10
		call	SendByte

StateInitPlayEnd:				
		movlw	0xC3
		call	SendFrameByte
		
		incfsz	BIDIcount, f
		return

		goto	SetStatePlayLeadIn
		
StateInitPlayAnnounceCD:		
		;; 0xF6..0xF0: CD-ROM Loaded (seen on changer)
		;; 0xE6..0xE0: CD-ROM Loaded. (made up)
		;; 0x96..0x90: Slot Empty (seen on changer)
		;; 0x86..0x80: Slot Empty (made up)
		;; 0xD6..0xD0: AUDIO CD Loaded. (seen on changer)
		movf	discload, w
		call	SendByte

		movlw	0xD6
		subwf	discload, w		; have we reached CD 6?
		movlw	0xD1			; if so, loop back to CD 1
		btfss	STATUS, Z
		incf	discload, w		; if not, go to next CD number.

		movwf	discload	

		call	SendDisplayBytesInitCD

		movlw	0x00
		call	SendByte

		goto	StateInitPlayEnd
		
;;; 34 BE FE FF FF FF AE 3C (play lead-in)
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
;;; 34 2E ED DE AF B7 FF 3C
;;; 34 BE FE FF FF FF AE 3C
StatePlayLeadIn:
		movlw	SECONDWAIT
		movwf	secondcount		; stop display from ticking time

		movlw	0xCB
		call	SendFrameByte

		btfss	BIDIcount, 0
		goto	StatePlayLeadInAnnounceCD

		call	SendDisplayBytes

		movlw	0x51
		call	SendByte
		
StatePlayLeadInEnd:
		movlw	0xC3
		call	SendFrameByte
		
		incfsz	BIDIcount, f
		return

		goto	SetStatePlay
		
StatePlayLeadInAnnounceCD
		movf	disc, w
		andlw	0x0F
		iorlw	0xD0
		call	SendByte

		call	SendDisplayBytesInitCD

		movlw	0x00
		call	SendByte

		goto	StatePlayLeadInEnd
		
StateTrackLeadIn:
		movlw	SECONDWAIT
		movwf	secondcount		; stop display from ticking time

		movlw	0xCB
		call	SendFrameByte

		call	SendDisplayBytes

		movlw	0x51
		call	SendByte

		movlw	0xC3
		call	SendFrameByte
		
		incfsz	BIDIcount, f
		return

		goto	SetStatePlay

StatePlay:
		movlw	0xCB
		call	SendFrameByte

		call	SendDisplayBytes

		movlw	0x30
		call	SendByte

		movlw	0xC3
		goto	SendFrameByte
			

;; --------------------------------------------------------------
;; Serial Strings.
;; Must stay within one 256 byte page boundary or else!
	ORG		0x300
	
SerialDataStrings:
sDATAERR:
	dt		"dataerr"
	goto	EndString

sOVERFLOW:
	dt		"overflow"
	goto	EndString

sMDIS:
	dt		"MDIS"
	goto	EndString

sMENABLE:
	dt		"MEN"
sABLE:
	dt		"ABLE"
	goto	EndString

sMINQUIRY:
	dt		"MINQUIRY"
	goto	EndString

sPRV:
	dt		"PRV"
	goto	EndString

sNXT_LIST:
	dt		"NXT"
s_LIST:
	dt		'_'
sLIST:
	dt		"LIST"
	goto	EndString

sRANDOM:
	dt		"RANDOM"
	goto	EndString

sPLAY:
	dt		"PLAY"
	goto	EndString

sNEXT:
	dt		"NEXT"
	goto	EndString

sPREVIOUS:
	dt		"PREVIOUS"
	goto	EndString

sRING:	
	dt		"RING"
	goto	EndString

sIDENTIFYNEWLINE:		
	dt		"VWCDPIC", VER_MAJOR, '.', VER_MINOR, VER_PATCHLEVEL

sNEWLINE:		
	dt		13, 10
	goto	EndString

s0:	dt		'0'
	goto	EndString
s1:	dt		'1'
	goto	EndString
s2:	dt		'2'
	goto	EndString
s3:	dt		'3'
	goto	EndString
s4:	dt		'4'
	goto	EndString
s5:	dt		'5'
	goto	EndString
s6:	dt		'6'
	goto	EndString
s7:	dt		'7'
	goto	EndString
s8:	dt		'8'
	goto	EndString
s9:	dt		'9'
	goto	EndString
sA:	dt		'A'
	goto	EndString
sB:	dt		'B'
	goto	EndString
sC:	dt		'C'
	goto	EndString
sD:	dt		'D'
	goto	EndString
sE:	dt		'E'
	goto	EndString
sF:	dt		'F'
	goto	EndString
sDASH:	dt		'-'
		goto	EndString
		
;--------------------------------------------------------------------------
; Archos Jukebox Serial Commands
; E0 Volume Down
; D0 Volume Up
; C8 Next (+)
; C4 Previous (-)
; C2 Stop
; C1 Play
;--------------------------------------------------------------------------
	IFDEF ARCHOS_SUPPORT

;;; The Volume UP/DOWN commands seem pretty useless to me in a car audio
;;; setting since the head unit has its own volume control built in.
; archosVOLDOWN:
; 	bsf		progflags, archos
;	retlw	0xE0			; Archos Volume Down

; archosVOLUP:
;	bsf		progflags, archos
;	retlw	0xD0			; Archos Volume Up

archosSTOP:
	bsf		progflags, archos
	retlw	0xC2			; Archos Stop

archosPLAY:
	bsf		progflags, archos
	retlw	0xC1			; Archos Play/Pause

archosNEXT:
	bsf		progflags, archos
	retlw	0xC8			; Archos Next (+)

archosPREVIOUS:
	bsf		progflags, archos
	retlw	0xC4			; Archos Previous (-)

archosMENABLE:
	bsf		progflags, archos	
	retlw	0xE4

archosMDISABLE:
	bsf		progflags, archos	
	retlw	0x10

archosMENU:
	bsf		progflags, archos	
	retlw	0xA0

archosSHUFFLE:
		bsf		progflags, archos
		retlw	0x49

archosLIST1:
		bsf		progflags, archos
		retlw	0xD1

archosLIST2:
		bsf		progflags, archos
		retlw	0xD2

archosLIST3:
		bsf		progflags, archos
		retlw	0xD3

archosLIST4:	
		bsf		progflags, archos
		retlw	0xD4
		
archosLIST5:
		bsf		progflags, archos
		retlw	0xD5

archosLIST6:
		bsf		progflags, archos
		retlw	0xD6

	ENDIF

	CRCMOD					; modify firmware CRC to be xx26 (v2.6)

;;; Command Codes
;;; -------------
;
; First byte is always 53
; Second byte is always 2C
; Third and Fourth bytes always add up to FF
; All command codes seem to be a multiple of 4.
;		
;		
; 53 2C 0C F3 CD 1
; 53 2C 10 EF DISABLE 
; 53 2C 14 EB Change CD (ignored)
; 53 2C 18 E7 Previous CD (only on Audi Concert <)		
; 53 2C 2C D3 CD 5 (first packet)
; 53 2C 38 C7 Change CD/Next CD (aka MINQUIRY)
; 53 2C 4C B3 CD 3 (first packet)
; 53 2C 58 A7 Seek Back Pressed
; 53 2C 60 9F Mix 1
; 53 2C 68 97 Up on Mk3 premium (Adam Yellen)
; 53 2C 78 87 Dn
; 53 2C 8C 73 CD 2 (first packet)
; 53 2C A0 5F Scan
; 53 2C A4 5B something to do with power on (Audi Concert)
; 53 2C A8 57 Dn on Mk3 premium (Adam Yellen <adam@yellen.com>)
; 53 2C AC 53 CD 6 (first packet)
; 53 2C CC 33 CD 4 (first packet)
; 53 2C D8 27 Seek Forward Pressed
; 53 2C E0 1F Mix 6
; 53 2C E4 1B ENABLE 
; 53 2C F8 07 Up

		ORG		0x3FF - 64
CommandVectorTable:		
CMD00:	goto	Do_UNKNOWNCMD
CMD04:	goto	Do_UNKNOWNCMD
CMD08:	goto	Do_PLAY			; mix button held down (RCD300 head unit only)
CMD0C:	goto	Do_CD1			; CD 1
CMD10:	goto	Do_DISABLE		; DISABLE
CMD14:  goto  	Do_CHANGECD		; Change CD (changer ignores & no ACK)
CMD18:	goto	Do_PREVCD		; PREVIOUS CD (Audi Concert head unit)
CMD1C:	goto	Do_UNKNOWNCMD
CMD20:	goto	Do_UNKNOWNCMD
CMD24:	goto	Do_UNKNOWNCMD
CMD28:	goto	Do_UNKNOWNCMD
CMD2C:	goto	Do_CD5			; CD 5
CMD30:	goto	Do_UNKNOWNCMD
CMD34:	goto	Do_UNKNOWNCMD
CMD38:	goto	Do_LOADCD		; LOAD CD (aka MINQUIRY). 
								; Also means "Next CD" if no CD button pressed
CMD3C:	goto	Do_UNKNOWNCMD
CMD40:	goto	Do_UNKNOWNCMD
CMD44:	goto	Do_UNKNOWNCMD
CMD48:	goto	Do_UNKNOWNCMD
CMD4C:	goto	Do_CD3			; CD 3
CMD50:	goto	Do_UNKNOWNCMD
CMD54:	goto	Do_UNKNOWNCMD
CMD58:	goto	Do_SEEKBACK		; SEEK BACK
CMD5C:	goto	Do_UNKNOWNCMD
CMD60:	goto	Do_MIX			; MIX 1 (mix tracks within one disc)
CMD64:	goto	Do_UNKNOWNCMD
CMD68:	goto	Do_UP			; UP (Mk3 head unit)
CMD6C:	goto	Do_UNKNOWNCMD
CMD70:	goto	Do_UNKNOWNCMD
CMD74:	goto	Do_UNKNOWNCMD
CMD78:	goto	Do_DOWN			; DOWN
CMD7C:	goto	Do_UNKNOWNCMD
CMD80:	goto	Do_UNKNOWNCMD
CMD84:	goto	Do_UNKNOWNCMD
CMD88:	goto	Do_UNKNOWNCMD
CMD8C:	goto	Do_CD2			; CD 2
CMD90:	goto	Do_UNKNOWNCMD
CMD94:	goto	Do_UNKNOWNCMD
CMD98:	goto	Do_UNKNOWNCMD
CMD9C:	goto	Do_UNKNOWNCMD
CMDA0:	goto	Do_SCAN			; SCAN
CMDA4:	goto	Do_UNKNOWNCMD	; power on CD mode?? (Audi Concert head unit)
CMDA8:	goto	Do_DOWN			; DOWN (Mk3 head unit only)
CMDAC:	goto	Do_CD6			; CD 6
CMDB0:	goto	Do_UNKNOWNCMD
CMDB4:	goto	Do_UNKNOWNCMD
CMDB8:	goto	Do_UNKNOWNCMD
CMDBC:	goto	Do_UNKNOWNCMD
CMDC0:	goto	Do_UNKNOWNCMD
CMDC4:	goto	Do_UNKNOWNCMD
CMDC8:	goto	Do_UNKNOWNCMD
CMDCC:	goto	Do_CD4			; CD 4
CMDD0:	goto	Do_UNKNOWNCMD
CMDD4:	goto	Do_UNKNOWNCMD
CMDD8:	goto	Do_SEEKFORWARD	; Seek Forward
CMDDC:	goto	Do_UNKNOWNCMD
CMDE0:	goto	Do_MIX			; MIX 6 (mix tracks across all discs)
CMDE4:	goto	Do_ENABLE		; ENABLE
CMDE8:	goto	Do_UNKNOWNCMD
CMDEC:	goto	Do_UNKNOWNCMD
CMDF0:	goto	Do_UNKNOWNCMD
CMDF4:	goto	Do_UNKNOWNCMD
CMDF8:	goto	Do_UP			; UP
CMDFC:	goto	Do_UNKNOWNCMD
		
	;;; Copyright notice stored in EEPROM data memory.
	ORG 2100h
	de		"VWCDPIC Firmware v", VER_MAJOR, ".", VER_MINOR, VER_PATCHLEVEL, "\n"
	de		"Copyright (c) 2002-2005, K9spud LLC.\n"
	de		"Licensed under GNU General Public License v2.\n"
	de		"www.k9spud.com\n"

	END
