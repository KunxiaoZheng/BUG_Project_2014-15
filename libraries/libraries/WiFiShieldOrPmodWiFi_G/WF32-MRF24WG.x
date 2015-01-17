/************************************************************************/
/*																		*/
/*	Uno32-MRF24WG.x                                                     */
/*																		*/
/*	MRF24WG WiFi interrupt and SPI configuration file 				    */
/*	Specific to the Uno32 WiFiShield                                    */
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
/*	10/16/2012 (KeithV): Updated to MLA v5.42-02 and MRF24WG			*/
/*																		*/
/************************************************************************/

#ifndef WF32_MRF24WG_X
#define WF32_MRF24WG_X

    // we need to slow it down for the MX1/2
    #define WF_MAX_SPI_FREQ 5000000ul

    #define __Digilent_Build__

    #define MRF24_USING_SPI4
    #define MRF24_USING_INT4

    #define WF_CS_TRIS          (TRISFbits.TRISF12)
    #define WF_CS_IO            (LATFbits.LATF12)
    #define WF_SDI_TRIS         (TRISFbits.TRISF4)
    #define WF_SCK_TRIS         (TRISFbits.TRISF13)
    #define WF_SDO_TRIS         (TRISFbits.TRISF5)
    #define WF_RESET_TRIS       (TRISGbits.TRISG0)
    #define WF_RESET_IO         (LATGbits.LATG0)
    #define WF_INT_TRIS         (TRISAbits.TRISA15)  // INT4
    #define WF_INT_IO           (PORTAbits.RA15)
    #define WF_HIBERNATE_TRIS   (TRISGbits.TRISG1)
    #define WF_HIBERNATE_IO     (PORTGbits.RG1)

    static inline void __attribute__((always_inline)) DNETcKInitNetworkHardware(void)
    {
        WF_HIBERNATE_IO     = 0;			
        WF_HIBERNATE_TRIS   = 0;

        WF_RESET_IO         = 0;		
        WF_RESET_TRIS       = 0;

        // Enable the WiFi
        WF_CS_IO            = 1;
        WF_CS_TRIS          = 0;

        WF_INT_TRIS         = 1;
    }

#endif // WF32_MRF24WG_X
