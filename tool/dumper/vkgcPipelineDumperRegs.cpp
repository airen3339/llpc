/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2020-2022 Advanced Micro Devices, Inc. All Rights Reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 **********************************************************************************************************************/
/**
***********************************************************************************************************************
* @file  vkgcPipelineDumperRegs.cpp
* @brief VKGC source file: register names for VKGC pipeline dump utility.
***********************************************************************************************************************
*/
#include "vkgcPipelineDumper.h"

namespace Vkgc {

// A single register in the pipelineDumperRegs table
struct PipelineDumperReg {
  unsigned number;
  const char *name;
};

const PipelineDumperReg PipelineDumperRegs[] = {
    {0x2C06, "SPI_SHADER_PGM_CHKSUM_PS"},
    {0x2C07, "SPI_SHADER_PGM_RSRC3_PS"},
    {0x2C0A, "SPI_SHADER_PGM_RSRC1_PS"},
    {0x2C0B, "SPI_SHADER_PGM_RSRC2_PS"},
    {0x2C0C, "SPI_SHADER_USER_DATA_PS_0"},
    {0x2C0D, "SPI_SHADER_USER_DATA_PS_1"},
    {0x2C0E, "SPI_SHADER_USER_DATA_PS_2"},
    {0x2C0F, "SPI_SHADER_USER_DATA_PS_3"},
    {0x2C10, "SPI_SHADER_USER_DATA_PS_4"},
    {0x2C11, "SPI_SHADER_USER_DATA_PS_5"},
    {0x2C12, "SPI_SHADER_USER_DATA_PS_6"},
    {0x2C13, "SPI_SHADER_USER_DATA_PS_7"},
    {0x2C14, "SPI_SHADER_USER_DATA_PS_8"},
    {0x2C15, "SPI_SHADER_USER_DATA_PS_9"},
    {0x2C16, "SPI_SHADER_USER_DATA_PS_10"},
    {0x2C17, "SPI_SHADER_USER_DATA_PS_11"},
    {0x2C18, "SPI_SHADER_USER_DATA_PS_12"},
    {0x2C19, "SPI_SHADER_USER_DATA_PS_13"},
    {0x2C1A, "SPI_SHADER_USER_DATA_PS_14"},
    {0x2C1B, "SPI_SHADER_USER_DATA_PS_15"},
    {0x2C1C, "SPI_SHADER_USER_DATA_PS_16"},
    {0x2C1D, "SPI_SHADER_USER_DATA_PS_17"},
    {0x2C1E, "SPI_SHADER_USER_DATA_PS_18"},
    {0x2C1F, "SPI_SHADER_USER_DATA_PS_19"},
    {0x2C20, "SPI_SHADER_USER_DATA_PS_20"},
    {0x2C21, "SPI_SHADER_USER_DATA_PS_21"},
    {0x2C22, "SPI_SHADER_USER_DATA_PS_22"},
    {0x2C23, "SPI_SHADER_USER_DATA_PS_23"},
    {0x2C24, "SPI_SHADER_USER_DATA_PS_24"},
    {0x2C25, "SPI_SHADER_USER_DATA_PS_25"},
    {0x2C26, "SPI_SHADER_USER_DATA_PS_26"},
    {0x2C27, "SPI_SHADER_USER_DATA_PS_27"},
    {0x2C28, "SPI_SHADER_USER_DATA_PS_28"},
    {0x2C29, "SPI_SHADER_USER_DATA_PS_29"},
    {0x2C2A, "SPI_SHADER_USER_DATA_PS_30"},
    {0x2C2B, "SPI_SHADER_USER_DATA_PS_31"},
    {0x2C45, "SPI_SHADER_PGM_CHKSUM_VS"},
    {0x2C46, "SPI_SHADER_PGM_RSRC3_VS"},
    {0x2C4A, "SPI_SHADER_PGM_RSRC1_VS"},
    {0x2C4B, "SPI_SHADER_PGM_RSRC2_VS"},
    {0x2C4C, "SPI_SHADER_USER_DATA_VS_0"},
    {0x2C4D, "SPI_SHADER_USER_DATA_VS_1"},
    {0x2C4E, "SPI_SHADER_USER_DATA_VS_2"},
    {0x2C4F, "SPI_SHADER_USER_DATA_VS_3"},
    {0x2C50, "SPI_SHADER_USER_DATA_VS_4"},
    {0x2C51, "SPI_SHADER_USER_DATA_VS_5"},
    {0x2C52, "SPI_SHADER_USER_DATA_VS_6"},
    {0x2C53, "SPI_SHADER_USER_DATA_VS_7"},
    {0x2C54, "SPI_SHADER_USER_DATA_VS_8"},
    {0x2C55, "SPI_SHADER_USER_DATA_VS_9"},
    {0x2C56, "SPI_SHADER_USER_DATA_VS_10"},
    {0x2C57, "SPI_SHADER_USER_DATA_VS_11"},
    {0x2C58, "SPI_SHADER_USER_DATA_VS_12"},
    {0x2C59, "SPI_SHADER_USER_DATA_VS_13"},
    {0x2C5A, "SPI_SHADER_USER_DATA_VS_14"},
    {0x2C5B, "SPI_SHADER_USER_DATA_VS_15"},
    {0x2C5C, "SPI_SHADER_USER_DATA_VS_16"},
    {0x2C5D, "SPI_SHADER_USER_DATA_VS_17"},
    {0x2C5E, "SPI_SHADER_USER_DATA_VS_18"},
    {0x2C5F, "SPI_SHADER_USER_DATA_VS_19"},
    {0x2C60, "SPI_SHADER_USER_DATA_VS_20"},
    {0x2C61, "SPI_SHADER_USER_DATA_VS_21"},
    {0x2C62, "SPI_SHADER_USER_DATA_VS_22"},
    {0x2C63, "SPI_SHADER_USER_DATA_VS_23"},
    {0x2C64, "SPI_SHADER_USER_DATA_VS_24"},
    {0x2C65, "SPI_SHADER_USER_DATA_VS_25"},
    {0x2C66, "SPI_SHADER_USER_DATA_VS_26"},
    {0x2C67, "SPI_SHADER_USER_DATA_VS_27"},
    {0x2C68, "SPI_SHADER_USER_DATA_VS_28"},
    {0x2C69, "SPI_SHADER_USER_DATA_VS_29"},
    {0x2C6A, "SPI_SHADER_USER_DATA_VS_30"},
    {0x2C6B, "SPI_SHADER_USER_DATA_VS_31"},
    {0x2C7B, "SPI_SHADER_PGM_RSRC2_GS_VS"},
    {0x2C7C, "SPI_SHADER_PGM_RSRC2_ES_VS"},
    {0x2C7C, "SPI_SHADER_PGM_RSRC2_GS_VS"},
    {0x2C7D, "SPI_SHADER_PGM_RSRC2_LS_VS"},
    {0x2C80, "SPI_SHADER_PGM_CHKSUM_GS"},
    {0x2C81, "SPI_SHADER_PGM_RSRC4_GS"},
    {0x2C87, "SPI_SHADER_PGM_RSRC3_GS"},
    {0x2C88, "SPI_SHADER_PGM_LO_GS"},
    {0x2C8A, "SPI_SHADER_PGM_RSRC1_GS"},
    {0x2C8B, "SPI_SHADER_PGM_RSRC2_GS"},
    {0x2C8C, "SPI_SHADER_USER_DATA_GS_0"},
    {0x2C8D, "SPI_SHADER_USER_DATA_GS_1"},
    {0x2C8E, "SPI_SHADER_USER_DATA_GS_2"},
    {0x2C8F, "SPI_SHADER_USER_DATA_GS_3"},
    {0x2C90, "SPI_SHADER_USER_DATA_GS_4"},
    {0x2C91, "SPI_SHADER_USER_DATA_GS_5"},
    {0x2C92, "SPI_SHADER_USER_DATA_GS_6"},
    {0x2C93, "SPI_SHADER_USER_DATA_GS_7"},
    {0x2C94, "SPI_SHADER_USER_DATA_GS_8"},
    {0x2C95, "SPI_SHADER_USER_DATA_GS_9"},
    {0x2C96, "SPI_SHADER_USER_DATA_GS_10"},
    {0x2C97, "SPI_SHADER_USER_DATA_GS_11"},
    {0x2C98, "SPI_SHADER_USER_DATA_GS_12"},
    {0x2C99, "SPI_SHADER_USER_DATA_GS_13"},
    {0x2C9A, "SPI_SHADER_USER_DATA_GS_14"},
    {0x2C9B, "SPI_SHADER_USER_DATA_GS_15"},
    {0x2C9C, "SPI_SHADER_USER_DATA_GS_16"},
    {0x2C9D, "SPI_SHADER_USER_DATA_GS_17"},
    {0x2C9E, "SPI_SHADER_USER_DATA_GS_18"},
    {0x2C9F, "SPI_SHADER_USER_DATA_GS_19"},
    {0x2CA0, "SPI_SHADER_USER_DATA_GS_20"},
    {0x2CA1, "SPI_SHADER_USER_DATA_GS_21"},
    {0x2CA2, "SPI_SHADER_USER_DATA_GS_22"},
    {0x2CA3, "SPI_SHADER_USER_DATA_GS_23"},
    {0x2CA4, "SPI_SHADER_USER_DATA_GS_24"},
    {0x2CA5, "SPI_SHADER_USER_DATA_GS_25"},
    {0x2CA6, "SPI_SHADER_USER_DATA_GS_26"},
    {0x2CA7, "SPI_SHADER_USER_DATA_GS_27"},
    {0x2CA8, "SPI_SHADER_USER_DATA_GS_28"},
    {0x2CA9, "SPI_SHADER_USER_DATA_GS_29"},
    {0x2CAA, "SPI_SHADER_USER_DATA_GS_30"},
    {0x2CAB, "SPI_SHADER_USER_DATA_GS_31"},
    {0x2CBC, "SPI_SHADER_PGM_RSRC2_ES_GS"},
    {0x2CCA, "SPI_SHADER_PGM_RSRC1_ES"},
    {0x2CCB, "SPI_SHADER_PGM_RSRC2_ES"},
    {0x2CCC, "SPI_SHADER_USER_DATA_ES_0"},
    {0x2CCD, "SPI_SHADER_USER_DATA_ES_1"},
    {0x2CCE, "SPI_SHADER_USER_DATA_ES_2"},
    {0x2CCF, "SPI_SHADER_USER_DATA_ES_3"},
    {0x2CD0, "SPI_SHADER_USER_DATA_ES_4"},
    {0x2CD1, "SPI_SHADER_USER_DATA_ES_5"},
    {0x2CD2, "SPI_SHADER_USER_DATA_ES_6"},
    {0x2CD3, "SPI_SHADER_USER_DATA_ES_7"},
    {0x2CD4, "SPI_SHADER_USER_DATA_ES_8"},
    {0x2CD5, "SPI_SHADER_USER_DATA_ES_9"},
    {0x2CD6, "SPI_SHADER_USER_DATA_ES_10"},
    {0x2CD7, "SPI_SHADER_USER_DATA_ES_11"},
    {0x2CD8, "SPI_SHADER_USER_DATA_ES_12"},
    {0x2CD9, "SPI_SHADER_USER_DATA_ES_13"},
    {0x2CDA, "SPI_SHADER_USER_DATA_ES_14"},
    {0x2CDB, "SPI_SHADER_USER_DATA_ES_15"},
    {0x2CDC, "SPI_SHADER_USER_DATA_ES_16"},
    {0x2CDD, "SPI_SHADER_USER_DATA_ES_17"},
    {0x2CDE, "SPI_SHADER_USER_DATA_ES_18"},
    {0x2CDF, "SPI_SHADER_USER_DATA_ES_19"},
    {0x2CE0, "SPI_SHADER_USER_DATA_ES_20"},
    {0x2CE1, "SPI_SHADER_USER_DATA_ES_21"},
    {0x2CE2, "SPI_SHADER_USER_DATA_ES_22"},
    {0x2CE3, "SPI_SHADER_USER_DATA_ES_23"},
    {0x2CE4, "SPI_SHADER_USER_DATA_ES_24"},
    {0x2CE5, "SPI_SHADER_USER_DATA_ES_25"},
    {0x2CE6, "SPI_SHADER_USER_DATA_ES_26"},
    {0x2CE7, "SPI_SHADER_USER_DATA_ES_27"},
    {0x2CE8, "SPI_SHADER_USER_DATA_ES_28"},
    {0x2CE9, "SPI_SHADER_USER_DATA_ES_29"},
    {0x2CEA, "SPI_SHADER_USER_DATA_ES_30"},
    {0x2CEB, "SPI_SHADER_USER_DATA_ES_31"},
    {0x2CFD, "SPI_SHADER_PGM_RSRC2_LS_ES"},
    {0x2D00, "SPI_SHADER_PGM_CHKSUM_HS"},
    {0x2D07, "SPI_SHADER_PGM_RSRC3_HS"},
    {0x2D0A, "SPI_SHADER_PGM_RSRC1_HS"},
    {0x2D0B, "SPI_SHADER_PGM_RSRC2_HS"},
    {0x2D0C, "SPI_SHADER_USER_DATA_HS_0"},
    {0x2D0C, "SPI_SHADER_USER_DATA_LS_0"},
    {0x2D0D, "SPI_SHADER_USER_DATA_HS_1"},
    {0x2D0D, "SPI_SHADER_USER_DATA_LS_1"},
    {0x2D0E, "SPI_SHADER_USER_DATA_HS_2"},
    {0x2D0E, "SPI_SHADER_USER_DATA_LS_2"},
    {0x2D0F, "SPI_SHADER_USER_DATA_HS_3"},
    {0x2D0F, "SPI_SHADER_USER_DATA_LS_3"},
    {0x2D10, "SPI_SHADER_USER_DATA_HS_4"},
    {0x2D10, "SPI_SHADER_USER_DATA_LS_4"},
    {0x2D11, "SPI_SHADER_USER_DATA_HS_5"},
    {0x2D11, "SPI_SHADER_USER_DATA_LS_5"},
    {0x2D12, "SPI_SHADER_USER_DATA_HS_6"},
    {0x2D12, "SPI_SHADER_USER_DATA_LS_6"},
    {0x2D13, "SPI_SHADER_USER_DATA_HS_7"},
    {0x2D13, "SPI_SHADER_USER_DATA_LS_7"},
    {0x2D14, "SPI_SHADER_USER_DATA_HS_8"},
    {0x2D14, "SPI_SHADER_USER_DATA_LS_8"},
    {0x2D15, "SPI_SHADER_USER_DATA_HS_9"},
    {0x2D15, "SPI_SHADER_USER_DATA_LS_9"},
    {0x2D16, "SPI_SHADER_USER_DATA_HS_10"},
    {0x2D16, "SPI_SHADER_USER_DATA_LS_10"},
    {0x2D17, "SPI_SHADER_USER_DATA_HS_11"},
    {0x2D17, "SPI_SHADER_USER_DATA_LS_11"},
    {0x2D18, "SPI_SHADER_USER_DATA_HS_12"},
    {0x2D18, "SPI_SHADER_USER_DATA_LS_12"},
    {0x2D19, "SPI_SHADER_USER_DATA_HS_13"},
    {0x2D19, "SPI_SHADER_USER_DATA_LS_13"},
    {0x2D1A, "SPI_SHADER_USER_DATA_HS_14"},
    {0x2D1A, "SPI_SHADER_USER_DATA_LS_14"},
    {0x2D1B, "SPI_SHADER_USER_DATA_HS_15"},
    {0x2D1B, "SPI_SHADER_USER_DATA_LS_15"},
    {0x2D1C, "SPI_SHADER_USER_DATA_HS_16"},
    {0x2D1C, "SPI_SHADER_USER_DATA_LS_16"},
    {0x2D1D, "SPI_SHADER_USER_DATA_HS_17"},
    {0x2D1D, "SPI_SHADER_USER_DATA_LS_17"},
    {0x2D1E, "SPI_SHADER_USER_DATA_HS_18"},
    {0x2D1E, "SPI_SHADER_USER_DATA_LS_18"},
    {0x2D1F, "SPI_SHADER_USER_DATA_HS_19"},
    {0x2D1F, "SPI_SHADER_USER_DATA_LS_19"},
    {0x2D20, "SPI_SHADER_USER_DATA_HS_20"},
    {0x2D20, "SPI_SHADER_USER_DATA_LS_20"},
    {0x2D21, "SPI_SHADER_USER_DATA_HS_21"},
    {0x2D21, "SPI_SHADER_USER_DATA_LS_21"},
    {0x2D22, "SPI_SHADER_USER_DATA_HS_22"},
    {0x2D22, "SPI_SHADER_USER_DATA_LS_22"},
    {0x2D23, "SPI_SHADER_USER_DATA_HS_23"},
    {0x2D23, "SPI_SHADER_USER_DATA_LS_23"},
    {0x2D24, "SPI_SHADER_USER_DATA_HS_24"},
    {0x2D24, "SPI_SHADER_USER_DATA_LS_24"},
    {0x2D25, "SPI_SHADER_USER_DATA_HS_25"},
    {0x2D25, "SPI_SHADER_USER_DATA_LS_25"},
    {0x2D26, "SPI_SHADER_USER_DATA_HS_26"},
    {0x2D26, "SPI_SHADER_USER_DATA_LS_26"},
    {0x2D27, "SPI_SHADER_USER_DATA_HS_27"},
    {0x2D27, "SPI_SHADER_USER_DATA_LS_27"},
    {0x2D28, "SPI_SHADER_USER_DATA_HS_28"},
    {0x2D28, "SPI_SHADER_USER_DATA_LS_28"},
    {0x2D29, "SPI_SHADER_USER_DATA_HS_29"},
    {0x2D29, "SPI_SHADER_USER_DATA_LS_29"},
    {0x2D2A, "SPI_SHADER_USER_DATA_HS_30"},
    {0x2D2A, "SPI_SHADER_USER_DATA_LS_30"},
    {0x2D2B, "SPI_SHADER_USER_DATA_HS_31"},
    {0x2D2B, "SPI_SHADER_USER_DATA_LS_31"},
    {0x2D3D, "SPI_SHADER_PGM_RSRC2_LS_HS"},
    {0x2D4A, "SPI_SHADER_PGM_RSRC1_LS"},
    {0x2D4B, "SPI_SHADER_PGM_RSRC2_LS"},
    {0x2D4C, "SPI_SHADER_USER_DATA_LS_0"},
    {0x2D4D, "SPI_SHADER_USER_DATA_LS_1"},
    {0x2D4E, "SPI_SHADER_USER_DATA_LS_2"},
    {0x2D4F, "SPI_SHADER_USER_DATA_LS_3"},
    {0x2D50, "SPI_SHADER_USER_DATA_LS_4"},
    {0x2D51, "SPI_SHADER_USER_DATA_LS_5"},
    {0x2D52, "SPI_SHADER_USER_DATA_LS_6"},
    {0x2D53, "SPI_SHADER_USER_DATA_LS_7"},
    {0x2D54, "SPI_SHADER_USER_DATA_LS_8"},
    {0x2D55, "SPI_SHADER_USER_DATA_LS_9"},
    {0x2D56, "SPI_SHADER_USER_DATA_LS_10"},
    {0x2D57, "SPI_SHADER_USER_DATA_LS_11"},
    {0x2D58, "SPI_SHADER_USER_DATA_LS_12"},
    {0x2D59, "SPI_SHADER_USER_DATA_LS_13"},
    {0x2D5A, "SPI_SHADER_USER_DATA_LS_14"},
    {0x2D5B, "SPI_SHADER_USER_DATA_LS_15"},
    {0x2E00, "COMPUTE_DISPATCH_INITIATOR"},
    {0x2E07, "COMPUTE_NUM_THREAD_X"},
    {0x2E08, "COMPUTE_NUM_THREAD_Y"},
    {0x2E09, "COMPUTE_NUM_THREAD_Z"},
    {0x2E12, "COMPUTE_PGM_RSRC1"},
    {0x2E13, "COMPUTE_PGM_RSRC2"},
    {0x2E15, "COMPUTE_RESOURCE_LIMITS"},
    {0x2E18, "COMPUTE_TMPRING_SIZE"},
    {0x2E25, "COMPUTE_SHADER_CHKSUM"},
    {0x2E28, "COMPUTE_PGM_RSRC3"},
    {0x2E2A, "COMPUTE_SHADER_CHKSUM"},
    {0x2E40, "COMPUTE_USER_DATA_0"},
    {0x2E41, "COMPUTE_USER_DATA_1"},
    {0x2E42, "COMPUTE_USER_DATA_2"},
    {0x2E43, "COMPUTE_USER_DATA_3"},
    {0x2E44, "COMPUTE_USER_DATA_4"},
    {0x2E45, "COMPUTE_USER_DATA_5"},
    {0x2E46, "COMPUTE_USER_DATA_6"},
    {0x2E47, "COMPUTE_USER_DATA_7"},
    {0x2E48, "COMPUTE_USER_DATA_8"},
    {0x2E49, "COMPUTE_USER_DATA_9"},
    {0x2E4A, "COMPUTE_USER_DATA_10"},
    {0x2E4B, "COMPUTE_USER_DATA_11"},
    {0x2E4C, "COMPUTE_USER_DATA_12"},
    {0x2E4D, "COMPUTE_USER_DATA_13"},
    {0x2E4E, "COMPUTE_USER_DATA_14"},
    {0x2E4F, "COMPUTE_USER_DATA_15"},
    {0xA08F, "CB_SHADER_MASK"},
    {0xA191, "SPI_PS_INPUT_CNTL_0"},
    {0xA192, "SPI_PS_INPUT_CNTL_1"},
    {0xA193, "SPI_PS_INPUT_CNTL_2"},
    {0xA194, "SPI_PS_INPUT_CNTL_3"},
    {0xA195, "SPI_PS_INPUT_CNTL_4"},
    {0xA196, "SPI_PS_INPUT_CNTL_5"},
    {0xA197, "SPI_PS_INPUT_CNTL_6"},
    {0xA198, "SPI_PS_INPUT_CNTL_7"},
    {0xA199, "SPI_PS_INPUT_CNTL_8"},
    {0xA19A, "SPI_PS_INPUT_CNTL_9"},
    {0xA19B, "SPI_PS_INPUT_CNTL_10"},
    {0xA19C, "SPI_PS_INPUT_CNTL_11"},
    {0xA19D, "SPI_PS_INPUT_CNTL_12"},
    {0xA19E, "SPI_PS_INPUT_CNTL_13"},
    {0xA19F, "SPI_PS_INPUT_CNTL_14"},
    {0xA1A0, "SPI_PS_INPUT_CNTL_15"},
    {0xA1A1, "SPI_PS_INPUT_CNTL_16"},
    {0xA1A2, "SPI_PS_INPUT_CNTL_17"},
    {0xA1A3, "SPI_PS_INPUT_CNTL_18"},
    {0xA1A4, "SPI_PS_INPUT_CNTL_19"},
    {0xA1A5, "SPI_PS_INPUT_CNTL_20"},
    {0xA1A6, "SPI_PS_INPUT_CNTL_21"},
    {0xA1A7, "SPI_PS_INPUT_CNTL_22"},
    {0xA1A8, "SPI_PS_INPUT_CNTL_23"},
    {0xA1A9, "SPI_PS_INPUT_CNTL_24"},
    {0xA1AA, "SPI_PS_INPUT_CNTL_25"},
    {0xA1AB, "SPI_PS_INPUT_CNTL_26"},
    {0xA1AC, "SPI_PS_INPUT_CNTL_27"},
    {0xA1AD, "SPI_PS_INPUT_CNTL_28"},
    {0xA1AE, "SPI_PS_INPUT_CNTL_29"},
    {0xA1AF, "SPI_PS_INPUT_CNTL_30"},
    {0xA1B0, "SPI_PS_INPUT_CNTL_31"},
    {0xA1B1, "SPI_VS_OUT_CONFIG"},
    {0xA1B3, "SPI_PS_INPUT_ENA"},
    {0xA1B4, "SPI_PS_INPUT_ADDR"},
    {0xA1B5, "SPI_INTERP_CONTROL_0"},
    {0xA1B6, "SPI_PS_IN_CONTROL"},
    {0xA1B8, "SPI_BARYC_CNTL"},
    {0xA1BA, "SPI_TMPRING_SIZE"},
    {0xA1C2, "SPI_SHADER_IDX_FORMAT"},
    {0xA1C3, "SPI_SHADER_POS_FORMAT"},
    {0xA1C4, "SPI_SHADER_Z_FORMAT"},
    {0xA1C5, "SPI_SHADER_COL_FORMAT"},
    {0xA1FF, "GE_MAX_OUTPUT_PER_SUBGROUP"},
    {0xA203, "DB_SHADER_CONTROL"},
    {0xA204, "PA_CL_CLIP_CNTL"},
    {0xA206, "PA_CL_VTE_CNTL"},
    {0xA207, "PA_CL_VS_OUT_CNTL"},
    {0xA210, "PA_STEREO_CNTL"},
    {0xA286, "VGT_HOS_MAX_TESS_LEVEL"},
    {0xA287, "VGT_HOS_MIN_TESS_LEVEL"},
    {0xA290, "VGT_GS_MODE"},
    {0xA291, "VGT_GS_ONCHIP_CNTL"},
    {0xA293, "PA_SC_MODE_CNTL_1"},
    {0xA295, "VGT_GS_PER_ES"},
    {0xA296, "VGT_ES_PER_GS"},
    {0xA297, "VGT_GS_PER_VS"},
    {0xA298, "VGT_GSVS_RING_OFFSET_1"},
    {0xA299, "VGT_GSVS_RING_OFFSET_2"},
    {0xA29A, "VGT_GSVS_RING_OFFSET_3"},
    {0xA29B, "VGT_GS_OUT_PRIM_TYPE"},
    {0xA2A1, "VGT_PRIMITIVEID_EN"},
    {0xA2A5, "VGT_GS_MAX_PRIMS_PER_SUBGROUP"},
    {0xA2AA, "IA_MULTI_VGT_PARAM"},
    {0xA2AA, "IA_MULTI_VGT_PARAM_BC"},
    {0xA2AB, "VGT_ESGS_RING_ITEMSIZE"},
    {0xA2AC, "VGT_GSVS_RING_ITEMSIZE"},
    {0xA2AD, "VGT_REUSE_OFF"},
    {0xA2B5, "VGT_STRMOUT_VTX_STRIDE_0"},
    {0xA2B9, "VGT_STRMOUT_VTX_STRIDE_1"},
    {0xA2BD, "VGT_STRMOUT_VTX_STRIDE_2"},
    {0xA2C1, "VGT_STRMOUT_VTX_STRIDE_3"},
    {0xA2CE, "VGT_GS_MAX_VERT_OUT"},
    {0xA2D3, "GE_NGG_SUBGRP_CNTL"},
    {0xA2D5, "VGT_SHADER_STAGES_EN"},
    {0xA2D6, "VGT_LS_HS_CONFIG"},
    {0xA2D7, "VGT_GS_VERT_ITEMSIZE"},
    {0xA2D8, "VGT_GS_VERT_ITEMSIZE_1"},
    {0xA2D9, "VGT_GS_VERT_ITEMSIZE_2"},
    {0xA2DA, "VGT_GS_VERT_ITEMSIZE_3"},
    {0xA2DB, "VGT_TF_PARAM"},
    {0xA2E4, "VGT_GS_INSTANCE_CNT"},
    {0xA2E5, "VGT_STRMOUT_CONFIG"},
    {0xA2E6, "VGT_STRMOUT_BUFFER_CONFIG"},
    {0xA2F8, "PA_SC_AA_CONFIG"},
    {0xA2F9, "PA_SU_VTX_CNTL"},
    {0xA310, "PA_SC_SHADER_CONTROL"},
    {0xA316, "VGT_VERTEX_REUSE_BLOCK_CNTL"},
    {0xC258, "IA_MULTI_VGT_PARAM"},
    {0xC258, "IA_MULTI_VGT_PARAM_PIPED"},
    {0xC25F, "GE_STEREO_CNTL"},
    {0xC262, "GE_USER_VGPR_EN"},
};

// =====================================================================================================================
// Get name of register, or "" if not known
//
// @param regNumber : Register number
const char *PipelineDumper::getRegisterNameString(unsigned regNumber) {
  for (unsigned idx = 0, end = sizeof(PipelineDumperRegs) / sizeof(PipelineDumperRegs[0]); idx != end; ++idx) {
    const auto &regEntry = PipelineDumperRegs[idx];
    if (regEntry.number == regNumber)
      return regEntry.name;
  }
  return "";
}

} // namespace Vkgc
