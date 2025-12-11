// ==============================================================
// Author : Joshua Muthenya Wambua
// Date : 10/12/2025
// System : 4-Way Traffic Light Controller with Pedestrian Interrupt
// Simulator : Jubin 8085 (RST 7_5, vector 003CH)
// Notes :
// - No EQU, DB, DW (Jubin does not accept them)
// - Interrupt is short (sets flag only)
// - Pedestrian service handled in main flow
// - Controller resumes exactly where it left off
// ==============================================================
// --------------------------------------------------------------
// RESET VECTOR
// --------------------------------------------------------------
# ORG 0000H
	   JMP START
// --------------------------------------------------------------
// RST 7_5 INTERRUPT VECTOR (003CH)
// --------------------------------------------------------------
# ORG 003CH
	   JMP PED_ISR	// short ISR → flag only
// --------------------------------------------------------------
// MEMORY LOCATIONS (use literal values only)
// --------------------------------------------------------------
// 9000H → pedestrian request flag
// 9001H → saved current traffic state
// --------------------------------------------------------------
// --------------------------------------------------------------
// MAIN PROGRAM
// --------------------------------------------------------------

START:	   EI	// enable interrupts
	   MVI A,08	// enable RST 7_5 (bit3)
	   SIM
// ------- STATE 0 : NS GREEN -------

MAIN_LOOP:	   MVI A,00
	   STA 9001	// save state
	   CALL NS_GREEN_PHASE
// ------- STATE 1 : NS YELLOW -------
	   MVI A,01
	   STA 9001
	   CALL NS_YELLOW_PHASE
// ------- STATE 2 : EW GREEN -------
	   MVI A,02
	   STA 9001
	   CALL EW_GREEN_PHASE
// ------- STATE 3 : EW YELLOW -------
	   MVI A,03
	   STA 9001
	   CALL EW_YELLOW_PHASE
// ------- CHECK PEDESTRIAN -------
	   CALL CHECK_PED
	   JMP MAIN_LOOP
// ==============================================================
// TRAFFIC LIGHT PHASES
// ==============================================================
// -------- NORTH-SOUTH GREEN --------

NS_GREEN_PHASE:	   MVI A,01
	   OUT 01	// NS Green
	   MVI A,04
	   OUT 02	// EW Red
	   CALL DELAY_10S
	   RET
// -------- NORTH-SOUTH YELLOW --------

NS_YELLOW_PHASE:	   MVI A,02
	   OUT 01	// NS Yellow
	   MVI A,04
	   OUT 02	// EW Red
	   CALL DELAY_3S
	   RET
// -------- EAST-WEST GREEN --------

EW_GREEN_PHASE:	   MVI A,04
	   OUT 01	// NS Red
	   MVI A,01
	   OUT 02	// EW Green
	   CALL DELAY_10S
	   RET
// -------- EAST-WEST YELLOW --------

EW_YELLOW_PHASE:	   MVI A,04
	   OUT 01	// NS Red
	   MVI A,02
	   OUT 02	// EW Yellow
	   CALL DELAY_3S
	   RET
// ==============================================================
// INTERRUPT SERVICE ROUTINE (SHORT)
// ==============================================================

PED_ISR:	   DI
	   MVI A,01
	   STA 9000	// set pedestrian request flag
	   EI
	   RET
// ==============================================================
// CHECK PEDESTRIAN FLAG
// ==============================================================

CHECK_PED:	   LDA 9000
	   CPI 01
	   JNZ NO_PED
// clear flag
	   MVI A,00
	   STA 9000
	   CALL SERVICE_PED

NO_PED:	   RET
// ==============================================================
// PEDESTRIAN SERVICE ROUTINE
// ==============================================================
// --- BOTH YELLOW ---

SERVICE_PED:	   MVI A,02
	   OUT 01
	   MVI A,02
	   OUT 02
	   CALL DELAY_3S
// --- BOTH RED ---
	   MVI A,04
	   OUT 01
	   MVI A,04
	   OUT 02
	   CALL DELAY_1S
// --- WALK ON ---
	   MVI A,01
	   OUT 03
	   CALL DELAY_5S
// --- WALK OFF ---
	   MVI A,00
	   OUT 03
// ---- resume previous traffic state ----
	   LDA 9001	// load saved state
	   CPI 00
	   JZ RESUME_NS_GREEN
	   CPI 01
	   JZ RESUME_NS_YELLOW
	   CPI 02
	   JZ RESUME_EW_GREEN
	   CPI 03
	   JZ RESUME_EW_YELLOW
	   RET	// fallback

RESUME_NS_GREEN:	   JMP NS_GREEN_PHASE

RESUME_NS_YELLOW:	   JMP NS_YELLOW_PHASE

RESUME_EW_GREEN:	   JMP EW_GREEN_PHASE

RESUME_EW_YELLOW:	   JMP EW_YELLOW_PHASE
// ==============================================================
// DELAYS
// ==============================================================

DELAY_10S:	   MVI B,0E

D10:	   CALL DELAY_1S
	   DCR B
	   JNZ D115
	   RET

DELAY_5S:	   MVI B,09

D5:	   CALL DELAY_1S
	   DCR B
	   JNZ 00D9
	   RET

DELAY_3S:	   MVI B,03

D3:	   CALL DELAY_1S
	   DCR B
	   JNZ D3
	   RET

DELAY_1S:	   LXI B,FFFF

D1:	   DCX B
	   MOV A,B
	   ORA C
	   JNZ D1
	   RET
# END
