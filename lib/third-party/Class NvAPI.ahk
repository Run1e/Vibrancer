Class NvAPI ; nvapi-min.ahk
{
	static DllFile := (A_PtrSize = 8) ? "nvapi64.dll" : "nvapi.dll"
	static hmod
	static quit := OnExit(ObjBindMethod(NvAPI, "_Delete"))
	
	static NVAPI_MAX_PHYSICAL_GPUS := 64
	static NVAPI_SHORT_STRING_MAX  := 64
	
	static ErrorMessage := False
	
	
	ClassInit()
	{
		if !(NvAPI.hmod := DllCall("LoadLibrary", "str", NvAPI.DllFile, "uptr"))
			return 2
		if (NvStatus := DllCall(DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x0150E828, "cdecl uptr"), "cdecl") != 0)
			return 1
		return false
	}
	
    ; ===========================================================================================================================
	
	EnumNvidiaDisplayHandle(thisEnum := 0)
	{
		static EnumNvidiaDisplayHandle := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x9ABDD40D, "cdecl uptr")
		if !(NvStatus := DllCall(EnumNvidiaDisplayHandle, "uint", thisEnum, "uint*", pNvDispHandle, "cdecl"))
			return pNvDispHandle
		return "*" NvStatus
	}
	
    ; ===========================================================================================================================
	
	EnumPhysicalGPUs()
	{
		static EnumPhysicalGPUs := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0xE5AC921F, "cdecl uptr")
		VarSetCapacity(nvGPUHandle, 4 * NvAPI.NVAPI_MAX_PHYSICAL_GPUS, 0)
		if !(NvStatus := DllCall(EnumPhysicalGPUs, "ptr", &nvGPUHandle, "uint*", pGpuCount, "cdecl"))
		{
			GPUH := []
			loop % pGpuCount
				GPUH[A_Index] := NumGet(nvGPUHandle, 4 * (A_Index - 1), "int")
			return GPUH
		}
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetAssociatedNvidiaDisplayHandle(thisEnum := 0)
	{
		static GetAssociatedNvidiaDisplayHandle := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x35C29134, "cdecl uptr")
		szDisplayName := NvAPI.GetAssociatedNvidiaDisplayName(thisEnum)
		if !(NvStatus := DllCall(GetAssociatedNvidiaDisplayHandle, "astr", szDisplayName, "int*", pNvDispHandle, "cdecl"))
			return pNvDispHandle
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetAssociatedNvidiaDisplayName(thisEnum := 0)
	{
		static GetAssociatedNvidiaDisplayName := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x22A78B05, "cdecl uptr")
		NvDispHandle := NvAPI.EnumNvidiaDisplayHandle(thisEnum)
		VarSetCapacity(szDisplayName, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(GetAssociatedNvidiaDisplayName, "ptr", NvDispHandle, "ptr", &szDisplayName, "cdecl"))
			return StrGet(&szDisplayName, "cp0")
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetDisplayDriverVersion()
	{
		static GetDisplayDriverVersion := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0xF951A4D1, "cdecl uptr")
		static NV_DISPLAY_DRIVER_VERSION := 12 + (2 * NvAPI.NVAPI_SHORT_STRING_MAX)
		hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
		VarSetCapacity(pVersion, NV_DISPLAY_DRIVER_VERSION, 0), NumPut(NV_DISPLAY_DRIVER_VERSION | 0x10000, pVersion, 0, "uint")
		if !(NvStatus := DllCall(GetDisplayDriverVersion, "ptr", hNvDisplay, "ptr", &pVersion, "cdecl"))
		{
			DV := {}
			DV.version             := NumGet(pVersion,    0, "uint")
			DV.drvVersion          := NumGet(pVersion,    4, "uint")
			DV.bldChangeListNum    := NumGet(pVersion,    8, "uint")
			DV.szBuildBranchString := StrGet(&pVersion + 12, NvAPI.NVAPI_SHORT_STRING_MAX, "cp0")
			DV.szAdapterString     := StrGet(&pVersion + 76, NvAPI.NVAPI_SHORT_STRING_MAX, "cp0")
			return DV
		}
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetDVCInfo(outputId := 0)
	{
		static GetDVCInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x4085DE45, "cdecl uptr")
		static NV_DISPLAY_DVC_INFO := 16
		hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
		VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO), NumPut(NV_DISPLAY_DVC_INFO | 0x10000, pDVCInfo, 0, "uint")
		if !(NvStatus := DllCall(GetDVCInfo, "ptr", hNvDisplay, "uint", outputId, "ptr", &pDVCInfo, "cdecl"))
		{
			DVC := {}
			DVC.version      := NumGet(pDVCInfo,  0, "uint")
			DVC.currentLevel := NumGet(pDVCInfo,  4, "uint")
			DVC.minLevel     := NumGet(pDVCInfo,  8, "uint")
			DVC.maxLevel     := NumGet(pDVCInfo, 12, "uint")
			return DVC
		}
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetDVCInfoEx(thisEnum := 0, outputId := 0)
	{
		static GetDVCInfoEx := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x0E45002D, "cdecl uptr")
		static NV_DISPLAY_DVC_INFO_EX := 20
		hNvDisplay := NvAPI.GetAssociatedNvidiaDisplayHandle(thisEnum)
		VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX), NumPut(NV_DISPLAY_DVC_INFO_EX | 0x10000, pDVCInfo, 0, "uint")
		if !(NvStatus := DllCall(GetDVCInfoEx, "ptr", hNvDisplay, "uint", outputId, "ptr", &pDVCInfo, "cdecl"))
		{
			DVC := {}
			DVC.version      := NumGet(pDVCInfo,  0, "uint")
			DVC.currentLevel := NumGet(pDVCInfo,  4, "int")
			DVC.minLevel     := NumGet(pDVCInfo,  8, "int")
			DVC.maxLevel     := NumGet(pDVCInfo, 12, "int")
			DVC.defaultLevel := NumGet(pDVCInfo, 16, "int")
			return DVC
		}
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetErrorMessage(ErrorCode)
	{
		static GetErrorMessage := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x6C2D048C, "cdecl uptr")
		VarSetCapacity(szDesc, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(GetErrorMessage, "ptr", ErrorCode, "wstr", szDesc, "cdecl"))
			return this.ErrorMessage ? "Error: " StrGet(&szDesc, "cp0") : "*" ErrorCode
		return NvStatus
	}
	
    ; ===========================================================================================================================
	
	GPU_GetThermalSettings(hPhysicalGpu := 0)
	{
		static GPU_GetThermalSettings := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0xE3640A56, "cdecl uptr")
		static NVAPI_MAX_THERMAL_SENSORS_PER_GPU := 3
		static NV_GPU_THERMAL_SETTINGS := 8 + (20 * NVAPI_MAX_THERMAL_SENSORS_PER_GPU)
		static NV_THERMAL_CONTROLLER := {-1: "UNKNOWN", 0: "NONE", 1: "GPU_INTERNAL", 2: "ADM1032", 3: "MAX6649"
                                        , 4: "MAX1617", 5: "LM99", 6: "LM89", 7: "LM64", 8: "ADT7473", 9: "SBMAX6649"
                                        ,10: "VBIOSEVT", 11: "OS"}
		static NV_THERMAL_TARGET := {-1: "UNKNOWN", 0: "NONE", 1: "GPU", 2: "MEMORY", 4: "POWERSUPPLY", 8: "BOARD"
                                    , 9: "VCD_BOARD", 10: "VCD_INLET", 11: "VCD_OUTLET", 15: "ALL"}
		if !(hPhysicalGpu)
			hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
		VarSetCapacity(pThermalSettings, NV_GPU_THERMAL_SETTINGS, 0), NumPut(NV_GPU_THERMAL_SETTINGS | 0x20000, pThermalSettings, 0, "uint")
		if !(NvStatus := DllCall(GPU_GetThermalSettings, "Ptr", hPhysicalGpu, "uint", 15, "Ptr", &pThermalSettings, "cdecl"))
		{
			TS := {}
			TS.version := NumGet(pThermalSettings, 0, "uint")
			TS.count   := NumGet(pThermalSettings, 4, "uint")
			OffSet := 8
			loop % NVAPI_MAX_THERMAL_SENSORS_PER_GPU
			{
				TS[A_Index, "controller"]     := (C := NV_THERMAL_CONTROLLER[NumGet(pThermalSettings, Offset, "uint")]) ? C : "UNKNOWN"
				TS[A_Index, "defaultMinTemp"] := NumGet(pThermalSettings, Offset +  4, "int")
				TS[A_Index, "defaultMaxTemp"] := NumGet(pThermalSettings, Offset +  8, "int")
				TS[A_Index, "currentTemp"]    := NumGet(pThermalSettings, Offset + 12, "int")
				TS[A_Index, "target"]         := (T := NV_THERMAL_TARGET[NumGet(pThermalSettings, Offset + 16, "uint")]) ? T : "UNKNOWN"
				OffSet += 20
			}
			return TS
		}
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GPU_GetFullName(hPhysicalGpu := 0)
	{
		static GPU_GetFullName := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0xCEEE8E9F, "cdecl uptr")
		if !(hPhysicalGpu)
			hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
		VarSetCapacity(szName, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(GPU_GetFullName, "ptr", hPhysicalGpu, "ptr", &szName, "cdecl"))
			return StrGet(&szName, "cp0")
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	SetDVCLevel(level, outputId := 0)
	{
		static SetDVCLevel := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x172409B4, "cdecl uptr")
		hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
		if !(NvStatus := DllCall(SetDVCLevel, "ptr", hNvDisplay, "uint", outputId, "uint", level, "cdecl"))
			return level
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	SetDVCLevelEx(currentLevel, thisEnum := 0, outputId := 0)
	{
		static SetDVCLevelEx := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x4A82C2B1, "cdecl uptr")
		static NV_DISPLAY_DVC_INFO_EX := 20
		hNvDisplay := NvAPI.GetAssociatedNvidiaDisplayHandle(thisEnum)
		VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX)
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).version,      pDVCInfo,  0, "uint")
        , NumPut(currentLevel,                              pDVCInfo,  4, "int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).minLevel,     pDVCInfo,  8, "int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).maxLevel,     pDVCInfo, 12, "int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).defaultLevel, pDVCInfo, 16, "int")
		return DllCall(SetDVCLevelEx, "ptr", hNvDisplay, "uint", outputId, "ptr", &pDVCInfo, "cdecl")
	}
	
    ; ===========================================================================================================================
	
	SYS_GetDriverAndBranchVersion()
	{
		static SYS_GetDriverAndBranchVersion := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0x2926AAAD, "cdecl uptr")
		VarSetCapacity(szBuildBranchString, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(SYS_GetDriverAndBranchVersion, "uint*", pDriverVersion, "ptr", &szBuildBranchString, "cdecl"))
		{
			DB := {}
			DB.pDriverVersion       := pDriverVersion
			DB.szBuildBranchString  := StrGet(&szBuildBranchString, "cp0")
			return DB
		}
		return NvAPI.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	_Delete()
	{
		DllCall(DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "uint", 0xD22BDD7E, "cdecl uptr"), "cdecl")
		if (NvAPI.hmod)
			DllCall("FreeLibrary", "ptr", NvAPI.hmod)
	}
}