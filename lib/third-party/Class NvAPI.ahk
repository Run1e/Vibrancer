class NvAPI ; nvapi-min.ahk
{
	static NvFile := (A_PtrSize = 8) ? "nvapi64.dll" : "nvapi.dll"
	
	static NVAPI_MAX_PHYSICAL_GPUS := 64
	static NVAPI_SHORT_STRING_MAX  := 64
	static NVAPI_ERROR_MESSAGE     := True
	
	__New()
	{
		static init
		if !(init)
		{
			if !(this.hNVAPI := DllCall("LoadLibrary", "str", this.NvFile, "uptr"))
				throw Exception("LoadLibrary failed: " A_LastError)
			if (this.NvInit := this.Initialize() != 0)
				throw Exception("An error occurred during the initialization process")
			init := true
		}
	}
	
    ; ===========================================================================================================================
	
	EnumNvidiaDisplayHandle(thisEnum := 0)
	{
		if !(NvStatus := DllCall(this.QueryInterface(0x9ABDD40D), "uint", thisEnum, "uint*", pNvDispHandle, "cdecl"))
			return pNvDispHandle
		return "*" NvStatus
	}
	
    ; ===========================================================================================================================
	
	EnumPhysicalGPUs()
	{
		VarSetCapacity(nvGPUHandle, this.NVAPI_MAX_PHYSICAL_GPUS * 4, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0xE5AC921F), "ptr", &nvGPUHandle, "uint*", pGpuCount, "cdecl"))
		{
			GPUH := []
			loop % pGpuCount
				GPUH.Push(NumGet(nvGPUHandle, 4 * (A_Index - 1), "int"))
			return GPUH
		}
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetAssociatedNvidiaDisplayHandle(thisEnum := 0)
	{
		szDisplayName := this.GetAssociatedNvidiaDisplayName(thisEnum)
		if !(NvStatus := DllCall(this.QueryInterface(0x35C29134), "astr", szDisplayName, "int*", pNvDispHandle, "cdecl"))
			return pNvDispHandle
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetAssociatedNvidiaDisplayName(thisEnum := 0)
	{
		NvDispHandle := this.EnumNvidiaDisplayHandle(thisEnum)
		VarSetCapacity(szDisplayName, this.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0x22A78B05), "ptr", NvDispHandle, "ptr", &szDisplayName, "cdecl"))
			return StrGet(&szDisplayName, "cp0")
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetDisplayDriverVersion()
	{
		static NV_DISPLAY_DRIVER_VERSION := 12 + (this.NVAPI_SHORT_STRING_MAX * 2)
		hNvDisplay := this.EnumNvidiaDisplayHandle()
		VarSetCapacity(pVersion, NV_DISPLAY_DRIVER_VERSION, 0), NumPut(NV_DISPLAY_DRIVER_VERSION | 0x10000, pVersion, 0, "uint")
		if !(NvStatus := DllCall(this.QueryInterface(0xF951A4D1), "ptr", hNvDisplay, "ptr", &pVersion, "cdecl"))
		{
			DV := {}
			DV.version             := NumGet(pVersion,    0, "uint")
			DV.drvVersion          := NumGet(pVersion,    4, "uint")
			DV.bldChangeListNum    := NumGet(pVersion,    8, "uint")
			DV.szBuildBranchString := StrGet(&pVersion + 12, this.NVAPI_SHORT_STRING_MAX, "cp0")
			DV.szAdapterString     := StrGet(&pVersion + 76, this.NVAPI_SHORT_STRING_MAX, "cp0")
			return DV
		}
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetDVCInfo(outputId := 0)
	{
		static NV_DISPLAY_DVC_INFO := 16
		hNvDisplay := this.EnumNvidiaDisplayHandle()
		VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO, 0), NumPut(NV_DISPLAY_DVC_INFO | 0x10000, pDVCInfo, 0, "uint")
		if !(NvStatus := DllCall(this.QueryInterface(0x4085DE45), "ptr", hNvDisplay, "uint", outputId, "ptr", &pDVCInfo, "cdecl"))
		{
			DVC := {}
			DVC.version      := NumGet(pDVCInfo,  0, "uint")
			DVC.currentLevel := NumGet(pDVCInfo,  4, "uint")
			DVC.minLevel     := NumGet(pDVCInfo,  8, "uint")
			DVC.maxLevel     := NumGet(pDVCInfo, 12, "uint")
			return DVC
		}
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetDVCInfoEx(thisEnum := 0, outputId := 0)
	{
		static NV_DISPLAY_DVC_INFO_EX := 20
		hNvDisplay := this.EnumNvidiaDisplayHandle()
		VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX, 0), NumPut(NV_DISPLAY_DVC_INFO_EX | 0x10000, pDVCInfo, 0, "uint")
		if !(NvStatus := DllCall(this.QueryInterface(0x0E45002D), "ptr", hNvDisplay, "uint", outputId, "ptr", &pDVCInfo, "cdecl"))
		{
			DVC := {}
			DVC.version      := NumGet(pDVCInfo,  0, "uint")
			DVC.currentLevel := NumGet(pDVCInfo,  4, "int")
			DVC.minLevel     := NumGet(pDVCInfo,  8, "int")
			DVC.maxLevel     := NumGet(pDVCInfo, 12, "int")
			DVC.defaultLevel := NumGet(pDVCInfo, 16, "int")
			return DVC
		}
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GetErrorMessage(NvStatus)
	{
		VarSetCapacity(szDesc, this.NVAPI_SHORT_STRING_MAX, 0)
		DllCall(this.QueryInterface(0x6C2D048C), "ptr", NvStatus, "wstr", szDesc, "cdecl")
		return (this.NVAPI_ERROR_MESSAGE) ? StrGet(&szDesc, "cp0") : "*" NvStatus
	}
	
    ; ===========================================================================================================================
	
	GPU_GetThermalSettings(hPhysicalGpu := 0)
	{
		static NVAPI_MAX_THERMAL_SENSORS_PER_GPU := 3
		static NV_GPU_THERMAL_SETTINGS := 8 + (20 * NVAPI_MAX_THERMAL_SENSORS_PER_GPU)
		static NV_THERMAL_CONTROLLER := {-1: "UNKNOWN", 0: "NONE", 1: "GPU_INTERNAL", 2: "ADM1032", 3: "MAX6649"
                                        , 4: "MAX1617", 5: "LM99", 6: "LM89", 7: "LM64", 8: "ADT7473", 9: "SBMAX6649"
                                        ,10: "VBIOSEVT", 11: "OS"}
		static NV_THERMAL_TARGET := {-1: "UNKNOWN", 0: "NONE", 1: "GPU", 2: "MEMORY", 4: "POWERSUPPLY", 8: "BOARD"
                                    , 9: "VCD_BOARD", 10: "VCD_INLET", 11: "VCD_OUTLET", 15: "ALL"}
		if !(hPhysicalGpu)
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		VarSetCapacity(pThermalSettings, NV_GPU_THERMAL_SETTINGS, 0), NumPut(NV_GPU_THERMAL_SETTINGS | 0x20000, pThermalSettings, 0, "uint")
		if !(NvStatus := DllCall(this.QueryInterface(0xE3640A56), "ptr", hPhysicalGpu, "uint", 15, "ptr", &pThermalSettings, "cdecl"))
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
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	GPU_GetFullName(hPhysicalGpu := 0)
	{
		if !(hPhysicalGpu)
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		VarSetCapacity(szName, this.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0xCEEE8E9F), "ptr", hPhysicalGpu, "ptr", &szName, "cdecl"))
			return StrGet(&szName, "cp0")
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	Initialize()
	{
		if !(NvStatus := DllCall(this.QueryInterface(0x0150E828), "cdecl"))
			return NvStatus
		return NvStatus
	}
	
    ; ===========================================================================================================================
	
	SetDVCLevel(level, outputId := 0)
	{
		hNvDisplay := this.EnumNvidiaDisplayHandle()
		if !(NvStatus := DllCall(this.QueryInterface(0x172409B4), "ptr", hNvDisplay, "uint", outputId, "uint", level, "cdecl"))
			return level
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	SetDVCLevelEx(currentLevel, thisEnum := 0, outputId := 0)
	{
		static NV_DISPLAY_DVC_INFO_EX := 20
		hNvDisplay := this.GetAssociatedNvidiaDisplayHandle(thisEnum)
		VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX)
        , NumPut(this.GetDVCInfoEx(thisEnum).version,      pDVCInfo,  0, "uint")
        , NumPut(currentLevel,                             pDVCInfo,  4, "int")
        , NumPut(this.GetDVCInfoEx(thisEnum).minLevel,     pDVCInfo,  8, "int")
        , NumPut(this.GetDVCInfoEx(thisEnum).maxLevel,     pDVCInfo, 12, "int")
        , NumPut(this.GetDVCInfoEx(thisEnum).defaultLevel, pDVCInfo, 16, "int")
		if !(NvStatus := DllCall(this.QueryInterface(0x4A82C2B1), "ptr", hNvDisplay, "uint", outputId, "ptr", &pDVCInfo, "cdecl"))
			return currentLevel
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	SYS_GetDriverAndBranchVersion()
	{
		VarSetCapacity(szBuildBranchString, this.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0x2926AAAD), "uint*", pDriverVersion, "ptr", &szBuildBranchString, "cdecl"))
		{
			DB := {}
			DB.pDriverVersion       := pDriverVersion
			DB.szBuildBranchString  := StrGet(&szBuildBranchString, "cp0")
			return DB
		}
		return this.GetErrorMessage(NvStatus)
	}
	
    ; ===========================================================================================================================
	
	Unload()
	{
		if !(NvStatus := DllCall(this.QueryInterface(0xD22BDD7E), "cdecl"))
			return NvStatus
		return NvStatus
	}
	
    ; ===========================================================================================================================
	
	QueryInterface(NvID)
	{
		return DllCall(this.NvFile "\nvapi_QueryInterface", "uint", NvID, "cdecl uptr")
	}
	
    ; ===========================================================================================================================
	
	__Delete()
	{
		if (this.NvInit = 0)
			if (this.Unload() != 0)
				throw Exception("One or more resources are locked and hence cannot unload NVAPI library")
		if (this.hNVAPI)
			DllCall("FreeLibrary", "ptr", this.hNVAPI)
	}
}