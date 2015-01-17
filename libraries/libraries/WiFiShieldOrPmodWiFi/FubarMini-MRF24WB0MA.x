/************************************************************************/
/*																		*/
/*	FubarMini-MRF24WB0MA.x                                              */
/*																		*/
/*	MRF24WB0MA WiFi interrupt and SPI configuration file 				*/
/*	Specific to the Fubarino Mini                                       */
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

#ifndef FBMINI_MRF24WB_X
#define FBMINI_MRF24WB_X

    // Digilent defined values for the MLA build
    #define __Digilent_Build__
    //#define __PIC32MX1XX__ 
    #define __PIC32MX2XX__

    // we need to slow it down for the MX1/2 on the MRF-B
    #define WF_MAX_SPI_FREQ 500000ul

    // Use connector J1 for the Pmod Shield, INT 4, SPI1
    #define MRF24_USING_SPI2
	#define MRF24_USING_INT4

	#define WF_CS_TRIS			(TRISAbits.TRISA0)          // RA0      ~CS
	#define WF_CS_IO			(LATAbits.LATA0)            // RA0      ~CS
	#define WF_SDI_TRIS			(TRISCbits.TRISC1)          // RC1      SDI2    SDI2R = 6  
	#define WF_SCK_TRIS			(TRISBbits.TRISB15)         // RB15     SCK2
	#define WF_SDO_TRIS			(TRISBbits.TRISB2)          // RB2      SDO2    RPB2R = 4 
	#define WF_RESET_TRIS		(TRISAbits.TRISA1)          // RA1      ~RST
	#define WF_RESET_IO			(LATAbits.LATA1)            // RA1      ~RST
	#define WF_INT_TRIS			(TRISCbits.TRISC0)          // RC0      INT4R = 6
	#define WF_INT_IO			(PORTCbits.RC0)             // RC0      INT4R = 6
	#define WF_HIBERNATE_TRIS	(TRISCbits.TRISC2)          // RC2      HIB
	#define WF_HIBERNATE_IO		(PORTCbits.RC2)             // RC2      HIB
    
    static inline void __attribute__((always_inline)) DNETcKInitNetworkHardware(void)
    {

        // clear my WiFi bits to make them digital
        ANSELACLR   = 0b0000000000000011;
        ANSELBCLR   = 0b1000000000000100;
        ANSELCCLR   = 0b0000000000000111;

        // set up the PPS
        RPB2R = 4;      // SDO2
        SDI2R = 6;      // SDI2          
        INT4R = 6;      // ~INT4

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

#endif // FBMINI_MRF24WB_X
