### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	DAP_INTERFACE_SUBROUTINES.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version from Luminary 099.
##		2016-10-18 RSB	Completed transcription.
##		2016-11-31 RSB	Typos.

## Page 473
		BANK	20
		EBANK=	DT

# MOD 0		DATE	11/15/66	BY GEORGE W. CHERRY

# FUNCTIONAL DESCRIPTION

#	   HEREIN IS A COLLECTION OF SUBROUTINES WHICH ALLOW MISSION CONTROL PROGRAMS TO CONTROL THE MODE
#	   AND INTERFACE WITH THE DAP.

# CALLING SEQUENCES

# IN INTERRUPT OR WITH INTERRUPT INHIBITED
#	   TC	  IBNKCALL
#	   FCADR  ROUTINE

# IN A JOB WITHOUT INTERRUPT INHIBITED
#	   INHINT
#	   TC	  IBNKCALL
#	   FCADR  ROUTINE
#	   RELINT

# OUTPUT
#	   SEE INDIVIDUAL ROUTINES BELOW

# DEBRIS
#	   A, L, AND SOMETIMES MDUETEMP

## Page 474
OURRCBIT	EQUALS	BIT1		# INTERNAL DAP RATE COMMAND ACTIVITY FLAG
TRYGIMBL	EQUALS	BIT2		# TRIM GIMBAL FLAG
DATAGOOD	EQUALS	BIT3		# RECIPROCAL ACCELERATIONS OKAY FLAG
ACC4OR2X	EQUALS	BIT4		# 2 OR 4 JET Z-TRANSLATION MODE FLAG
AORBSYST	EQUALS	BIT5		# P-AXIS ROTATION JET SYSTEM (A OR B) FLAG
ULLAGER		EQUALS	BIT6		# INTERNALL ULLAGE REQUEST FLAG
DBSELECT	EQUALS	BIT7		# DAP DEADBAND SELECT FLAG
APSGOING	EQUALS	BIT8		# ASCENT PROPULSION SYSTEM BURN FLAG
VIZPHASE	EQUALS	BIT9		# DESCENT VISIBILITY PHASE FLAG
PULSES		EQUALS	BIT10		# MINIMUM IMPULSE RHC MODE FLAG
GODAPGO		EQUALS	BIT11		# DAP ENABLING FLAG
MASSGOOD	EQUALS	BIT12		# MASS OKAY FLAG

# STILL AVAILABLE BIT13

AUTORHLD	EQUALS	BIT14		# AUTOMATIC MODE RATE HOLD FLAG
SPSBACUP	EQUALS	BIT15		# SPS BACKUP DAP FLAG


USEQRJTS	EQUALS	TRYGIMBL	# ALTERNATE TRIM GIMBAL FLAG

#              BIT     FLAGWORD   SWITCH   SWITCH    ON-STATE                      OFF-STATE
# LOCATION    NUMBER    SYMBOL    NUMBER   SYMBOL    INDICATES                     INDICATES
# --------   --------  --------   ------   ------    ---------                     ---------

# DAPBOOLS      1      OURRCBIT     59               INTERNAL RATE COMMAND         NO INTERNAL RATE COMMAND
#							ACTIVITY		      ACTIVITY  (LOCKED ON 0)
#               2      TRYGIMBL     58               TRIM GIMBAL CONTROL           TRIM GIMBAL CONTROL POSSIBLE
#							IMPOSSIBLE
#               3      DATAGOOD     57               RECIPROCAL ACCELERATION       RECIPROCAL ACCELERATION
#							PROBABLY CORRECT              PROBABLY INCORRECT
#               4      ACC4OR2X     56               P-AXIS 4 JET                  P-AXIS 2 JET
#							X-TRANSLATION MODE	      X-TRANSLATION MODE
#							(LOCKED ON 1)
#		5      AORBSYST     55		     P-FORCE COUPLES 15, 7 AND     P-FORCE COUPLES 4, 12 AND 3, 11
#							16, 8
#		6      ULLAGER      54               INTERNAL ULLAGE REQUEST       NO INTERNAL ULLAGE REQUEST
#		7      DBSELECT     53		     MAX DEADBAND SELECT	   MIN DEADBAND SELECT
#               8      APSGOING     52         	     ASCENT PROPULSION SYSTEM      APS OFF
#							BURN
#     		9      VIZPHASE	    51		     DESCENT VISIBILITY PHASE	   NOT IN DESCENT VISIBILITY
#							(LOCKED ON 1)		      PHASE
#	       10      PULSES       50		     MINIMUM IMPULSE RHC MODE	   RATE COMMAND RHC MODE
#	       11      GODAPGO      49               DAP ENABLED		   DAP IDLING
#	       12      MASSGOOD     48		     VALUE OF MASS PROBABLY	   VALUE OF MASS PROBABLY
#							CORRECT			      INCORRECT
## Page 475
#	       13                   47               NOT AVAILABLE - STATE
#							IRRELEVANT
#              14      AUTORHLD     46		     AUTOMATIC RATE HOLD MODE	   AUTOMATIC ATTITUDE HOLD
#	       15      SPSBACUP     45		     NOT IN SPS BACK-UP DAP MODE   SPS BACK-UP DAP MODE
#							(LOCKED ON 1)

SETMINDB	CAF	NARROWDB
		TS	DB
		CS	DBSELECT
		MASK	DAPBOOLS
		TS	DAPBOOLS
		TC	Q
		
SETMAXDB	CAF	WIDEDB
		TS	DB
		CS	DAPBOOLS
		MASK	DBSELECT
		ADS	DAPBOOLS
		TC	Q
		
ULLAGE		CS	DAPBOOLS
		MASK	ULLAGER
		ADS	DAPBOOLS
		TC	Q
		
NOULLAGE	CS	ULLAGER
		MASK	DAPBOOLS
		TS	DAPBOOLS
		TC	Q
		
HOLDRATE	TCF	COMNEXIT		# REPLACE BY  CS DAPBOOLS  FOR RATE HOLD.
		MASK	AUTORHLD
		ADS	DAPBOOLS
		
		CAF	EBANK6
		XCH	EBANK
		TS	OMEGARD
		
		EXTEND
		DCA	OMEGAP
		DXCH	OMEGAPD
		CAE	OMEGAR
		XCH	OMEGARD
		
		TS	EBANK
		
COMNEXIT	EXTEND
		DCA	CDUY
## Page 476
		DXCH	CDUYD
		CAE	CDUX
		TS	CDUXD
		
		TC	Q
		
STOPRATE	CS	AUTORHLD
		MASK	DAPBOOLS
		TS	DAPBOOLS
		
		CAF	ZERO
		TS	OMEGARD
		TS	OMEGAQD
		TS	OMEGARD
		TS	DELCDUX
		TS	DELCDUY
		TS	DELCDUZ
		TCF	COMNEXIT
		
SETRATE		EQUALS	HOLDRATE

## Page 477
# SUBROUTINE NAME: 1. UPCOAST     MOD. NO. 1  DATE: DECEMBER 4, 1966
#		   2. ALLCOAST
#		   3. WCHANGE

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# "UPCOAST" SETS UP DAP VARIABLES TO THEIR ASCENT-COAST VALUES.

# GROUNDRULE: IT MUST BE CALLED AS SOON AS ASCENT COAST IS DETECTED.

# "ALLCOAST" SETS UP MANY DAP VARIABLES FOR "STARTDAP" IN "DAPIDLER".

# GROUNDRULE: DESCOAST IS CALLED AS SOON AS DESCENT COAST IS DETECTED.

# "WCHANGE" SETS UP THE VARIABLE FOR "WCHANGER" AS A STORAGE SAVING DEVICE.

# CALLING SEQUENCE: (SAME AS ABOVE.)

# SUBROUTINES CALLED: NONE.

# ZERO: AOSQ,AOSR,AOSU,AOSV,AOSQTERM,AOSRTERM,ALL NJS.

# SET URGRATQ AND URGRATR TO POSMAX.

# OUTPUT: WFORP   (1-K)    MINIMPDB  APSGOING/DAPBOOLS
#          WFORQR  (1-K)/8  DBMINIMP  1/AMINQ  1/AMINR  1/AMINU  1/AMINV
# DEBRIS: A,L.

# ***** WARNING. *****  EBANK MUST BE SET TO 6.

		BANK	20
		EBANK=	WFORP
		
ALLCOAST	CAF	EBANK6
		XCH	EBANK
		TS	ITEMP6
		
		CS	APSGOING
		MASK	DAPBOOLS
		TS	DAPBOOLS
		
		CAF	NEGONE		# MAKES SPECIAL DAP APS CODING INACTIVE
		TS	AOSCOUNT
		CAF	0.00444
		TS	MINIMPDB	# IMPULSE DBS ARE SET OT 0.8 DEGREES.
		TS	DBMNMPAX	# (AND P-AXIS VALUE)
		TS	DBMINIMP
		
		CAF	POSMAX		# SET URGENCY FUNCTION CORRECTION RATIOS
		TS	URGRATQ		# TO ALMOST 1 BEFORE BEING SET IN AOSJOB.
		
## Page 478
		TS	URGRATR		# SCALED AT 1.
		
		CAF	ACCFIFTY	# INVERSE MINIMUM ACCELERATIONS ARE SET TO
		TS	1/AMINQ		# 50 SECONDS(2)/RADIAN.  THESE VARIABLES
		TS	1/AMINR		# ARE SET TO HALF THAT VALUE WITH THE
		TS	1/AMINU		# SCALE FACTOR 2(+8)/PI.
		TS	1/AMINV

		CAF	13DEC		# ZERO THE FOLLOWING DAP ERASABLES:
CLEARASC	TS	KCOEFCTR	# AOSQ  AOSQTERM  NJ+Q  NJ+U
		CAF	ZERO		# AOSR  AOSRTERM  NJ-Q  NJ-U
		INDEX	KCOEFCTR	# AOSU		  NJ+R  NJ+V
		TS	AOSQ		# AOSV            NJ-R  NJ-V
		CCS	KCOEFCTR
		TCF	CLEARASC
		
WCHANGE		CAF	0.3125		# K = 0.5
		TS	WFORP		# WFORP = WFORQR = K/DT = K/.1 = 10K = 5
		TS	WFORQR		# SCALED AT 16 PER SECOND.
		
		EXTEND			# K = 0.5 IMPLIES (1-K) = 0.5:
		DCA	(1-K)S		# (1-K)   = 0.5    SINCE SCALED AT 1.
		DXCH	(1-K)		# (1-K)/8 = 0.0625 SINCE SCALED AT 8.
		
# *** NOTE THAT STARTDAP RESETS WFORP,WFORQR,(1-K),(1-K)/8. ***

		CAE	ITEMP6
		TS	EBANK
		
		TC	Q		# RETURN
		
		
0.3DEGDB	DEC	0.00167
13DEC		DEC	13

## Page 479
# APS AND DPS ENGINE-ON ROUTINES (MUST BE CALLED WITH INTERRUPT INHIBIT)
# THE NAMES ENGINEON, ENGINOFF, AND ENGINOF1 ARE PRESERVED TO KEEP CURRENT
# SIMULATIONS AND EDITS OUT OF TROUBLE.

APSENGON	CAF	EBANK6
		XCH	EBANK
		TS	TEVENT	+1
		
		CS	ZERO		# DUMMYFIL WILL SET APSGOING BIT BECAUSE
		TS	AOSCOUNT	# OF MINUS ZERO IN AOSCOUNT
		CAF	PGNSCADR	# ACTIVATE PGNCS MONITOR
		
# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967******************
20INSRT		TCF	20INSRTA	# STORE TIME FOR ENGINOFF DELAY LOGIC.
# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967****END CODING FOR MODULE  3 REMAKE, AUGUST 1967******************
		CS	DAPBOOLS	# TURN TRIM GIMBAL OFF IN CASE WE DID FITH
		MASK	USEQRJTS
		ADS	DAPBOOLS
		
		CS	INPARAB		# MODIFY THE TJETLAW FOR ASCENT BURNS:
		TS	MINIMPDB	# (IN ONE EQUATION DELETE MINIMPDB AND
		CAF	ZERO		# SHIFT THE SWITCHING CURVE TO THE ORIGIN)
		TS	DBMINIMP	# MINIMPDB = -DB, DBMINIMP = 0
		
		EXTEND			# SET UP ASCENT URGENCY LIMITS SCALED AT
		DCA	ASCRATEC	# -2.0 DEGREES/SECOND SCALED AT PI/4 LIMIT
		DXCH	-2JETLIM	# -1.0 DEGREES/SECOND SCALED AT PI/4 DB
		
		CAF	-.06ACC		# SET ACC. LIMIT FOR INVERSE CALCULATION
		TS	-.06R/S2	# HERE FOR STAGING AT APS BURN.
		TCF	ENGINEON	# BYPASS THE SPECIAL DPS MONITOR SETUP
		
-.06ACC		DEC	-.03820		# -0.06 RADIANS/SECOND(2) AT PI/2

INPARAB		DEC	+.00333		# NOT FOR AS206 USE -.6DB NOT -DB

DPSENGON	CA	EBANK		# SAVE CALLER'S EBANK
		TS	TEVENT	+1	
		CAF	GMBLMNAD	# GMBLEMON HANDLES THE TRIM GIMBAL ON/OFF
					# LOGIC AND EXITS TO PGNCSMON
					
# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967******************

INSERT20	TCF	SETCNTR		# SET FLAGS FOR CRITICAL GTS ENTRIES.

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967****END CODING FOR MODULE  3 REMAKE, AUGUST 1967******************

## Page 480
		CS	BIT4		# CLEAR GIMBLMON INHIBIT FLAG JUST IN CASE
		MASK	FLAGWRD2	# IT HAD NOT BEEN RESET BY THROTTLE CONTRO
		TS	FLAGWRD2
		
ENGINEON	EXTEND			# THE ENGINE-ON COMMAND IS RECORDED
		DCA	TIME2		# FOR THE DOWNLINK
		DXCH	TEVENT

		CA	STOPDVC
		TS	SETDVCNT
		CA	BURNDB		# SET ONE DEGREE DEADBAND FOR THE BURN
		TS	DB
		
		CS	PRIO30		# TURN ON THE ENGINE - APS OR DPS
		EXTEND			# DEPENDING ON THE ARM COMMAND
		RAND	11
		AD	BIT13
		EXTEND
		WRITE	11
		
		CS	FLAGWRD1	# SET ENGINBIT - THE BIT WILL BE CLEARED
		MASK	ENGINBIT	# IN ENGINOFF AND THUS NODV CAN CHECK IT
		ADS	FLAGWRD1	# TO ASCERTAIN NORMAL OR PREMATURE CUTOFF
		
		CA	EBANK5
		TS	EBANK
		EBANK=	DVCNTR
		CA	STARTDVC	# SET UP THE DV MONITOR
		TS	DVCNTR
		LXCH	EBANK		# RESTORE CALLER:S EBANK
		TC	Q		# RETURN TO CALLER
		
## Page 481
# APS AND DPS ENGINE - OFF ROUTINE ( CALL WITH INTERRUPT INHIBITED )

# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967******************
ENGINOFF	TCF	20INSRTB	# PROCEED TO ENGINOFF DELAY LOGIC.

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967****END CODING FOR MODULE  3 REMAKE, AUGUST 1967******************
		TC	ALLCOAST	# DO DAP COASTING FLIGHT INITIALIZATION.

		EXTEND
		DCA	TIME2		# THE ENGINE - OFF COMMAND IS RECORDED
		DXCH	TEVENT		# FOR THE DOWNLINK

# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967******************
		EXTEND			# RESTORE ORIGINAL Q SETTING.
		QXCH	/TEMP1/

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967****END CODING FOR MODULE  3 REMAKE, AUGUST 1967******************
		CS	DAPBOOLS	# TURN TRIM GIMBAL OFF.
		MASK	USEQRJTS
		ADS	DAPBOOLS
		CAF	PGNSCADR	# MAKE SURE GIMBLMON DOES NOT TURN GIMBAL
		TS	DVSELECT	# BACK ON.
		
ENGINOF1	CS	PRIO30		# TURN OFF THE ENGINE
		EXTEND
		RAND	11
		AD	BIT14
		EXTEND
		WRITE	11
		
		CS	ENGINBIT	# CLEAR ENGINBIT - THIS IS AN INDICATION
		MASK	FLAGWRD1	# OF NORMAL SHUTDOWN
		TS	FLAGWRD1

# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967******************

INSRT20A	TCF	RESETCTR	# GO DEACTIVATE EXTRAORDINARY GTS FLAGS.

					# THEN RETURN TO CALLER.
# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967****END CODING FOR MODULE  3 REMAKE, AUGUST 1967******************

ENGINBIT	EQUALS	BIT5
ASCURGLM	DEC	-0.25	B-9	# -0.25 SECONDS SCALED AT 2(+9).
		DEC	-0.25	B-4	# -0.25 SECONDS SCALED AT 2(+4).
ASCRATEC	OCTAL	77001		# -1.4 DEG/SEC SCALED AT PI/4 RADIANS/SEC
		OCTAL	77555		# -0.4 DEG/SEC SCALED AT PI/4 RADIANS/SEC

1STENGOF	LXCH	Q		# COME HERE FROM FRESH START.
		TC	ENGINOF1	# JUST TURN OFF ENGINE
		LXCH	Q
		
## Page 482
		TCF	ALLCOAST	# AND SET UP FOR COAST.
