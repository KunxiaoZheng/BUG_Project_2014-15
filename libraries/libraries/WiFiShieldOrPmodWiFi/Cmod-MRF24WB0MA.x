/************************************************************************/
/*																		*/
/*	CmodCK1-MRF24WB0MA.x                                                */
/*																		*/
/*	MRF24WB0MA WiFi interrupt and SPI configuration file 				*/
/*	Specific to the CmodCK1                                             */
/*																		*/
/************************************************************************/
/*	Author: 	Keith Vogel 											*/
/*	Copyright 2011, Digilent Inc.										*/
/************************************************************************/
/*
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	1/25/2012(KeithV): Created											*/
/*	5/2/2012(KeithV): Updated to support a WiFiShield					*/
/*																		*/
/************************************************************************/

#ifndef CMODCK1_MRF24WB0MA_X
#define CMODCK1_MRF24WB0MA_X

    // Digilent defined values for the MLA build
    #define __Digilent_Build__
    #define __PIC32MX1XX__ 
    // #define __PIC32MX2XX__

    // we need to slow it down for the MX1/2 on the MRF-B
    #define WF_MAX_SPI_FREQ 500000ul

    // Use connector J1 for the Pmod Shield, INT3, SPI1
    #define MRF24_USING_SPI1
	#define MRF24_USING_INT3

	#define WF_CS_TRIS			(TRISCbits.TRISC0)          // RC0      ~CS
	#define WF_CS_IO			(LATCbits.LATC0)            // RC0      ~CS
	#define WF_SDI_TRIS			(TRISBbits.TRISB5)          // RB5      SDI1    SDI1R = 1  
	#define WF_SCK_TRIS			(TRISBbits.TRISB14)         // RB14     SCK1
	#define WF_SDO_TRIS			(TRISCbits.TRISC1)          // RC1      SDO1    RPC1R = 3 
	#define WF_INT_TRIS			(TRISCbits.TRISC8)          // RC8      INT3    INT3R = 6
	#define WF_INT_IO			(PORTCbits.RC8)             // RC8      INT3    INT3R = 6
	#define WF_RESET_TRIS		(TRISCbits.TRISC7)          // RC7      ~RST
	#define WF_RESET_IO			(LATCbits.LATC7)            // RC7      ~RST
	#define WF_HIBERNATE_TRIS	(TRISCbits.TRISC9)          // RC9      HIB
	#define WF_HIBERNATE_IO		(PORTCbits.RC9)             // RC9      HIB

    static inline void __attribute__((always_inline)) DNETcKInitNetworkHardware(void)
    {
        // clear my WiFi bits to make them digital
        ANSELBCLR   = 0b0100000000000000;
        ANSELCCLR   = 0b0000000000000011;

        // set up the PPS
        RPC1R = 3;      // SDO1
        SDI1R = 1;      // SDI1          
        INT3R = 6;      // ~INT3

        // Hibernate enables the regulators on the MRF24
        // This causes a huge inrush of current and can
        // actually cause the PIC32 to reset.
        // Since we have a pull down resistor on the HIB
        // pin, the regulators should be ON already when we
        // powered to board, to keep from pulsing the regulators
        // keep them ON and do NOT toggle them OFF unless we
        // explicitly do so in software later.
        WF_HIBERNATE_IO     = 0;			
        WF_HIBERNATE_TRIS   = 0;

        // keep the MRF24 in reset until after HIB goes low
        // delays have to be observed
        WF_RESET_IO         = 0;		
        WF_RESET_TRIS       = 0;

        // Deselect the MRF24
        WF_CS_IO            = 1;
        WF_CS_TRIS          = 0;

        // explicitly make the MRF24 interrupt an input pin
        // this should be the default, but is a PPS so to be safe
        // lets explicitly set it.
        WF_INT_TRIS         = 1;
    }

#endif // CMODCK1_MRF24WB0MA_X
