local bit = require("bit")
local X64 = (ffi.sizeof('intptr_t') == 8)
local X32 = (ffi.sizeof('intptr_t') == 4)
local hook = {}
dce_rpc_uuid_func = {
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@8"] = "ept_map_auth_async",
    ["12345678-1234-abcd-ef00-0123456789ab@91"] = "RpcGetSpoolFileInfo",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@77"] = "LlsrReplicationCertDbAddW",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@10"] = "DsRolerAbortDownlevelServerUpgrade",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@88"] = "LlsrLocalServiceInfoGetA",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d6@3"] = "RpcSrvRequestParams",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@8"] = "LlsrProductAddW",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@6"] = "RpcSrvFallbackRefreshParams",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@37"] = "NetrShareDelStart",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@38"] = "RpcServerNWLogonSetAdmin",
    ["12345678-1234-abcd-ef00-0123456789ab@92"] = "RpcCommitSpoolData",
    ["000001a0-0000-0000-c000-000000000046@1"] = "AddRefIRemoteISCMActivator",
    ["12345678-1234-abcd-ef00-01234567cffb@42"] = "NetrServerTrustPasswordsGet",
    ["12345778-1234-abcd-ef00-0123456789ac@20"] = "SamrQueryInformationGroup",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@18"] = "NetrDfsFlushFtTable",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@10"] = "RpcWinStationConnect",
    ["12345778-1234-abcd-ef00-0123456789ab@11"] = "LsarEnumerateAccounts",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@13"] = "R_WinsGetNameAndAdd",
    ["12345778-1234-abcd-ef00-0123456789ab@10"] = "LsarCreateAccount",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@2"] = "FrsRpcStartPromotionParent",
    ["c386ca3e-9061-4a72-821e-498d83be188f@12"] = "AudioSessionGetState",
    ["12345678-1234-abcd-ef00-01234567cffb@40"] = "DsrEnumerateDomainTrusts",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@15"] = "NetrShareEnum",
    ["00000143-0000-0000-c000-000000000046@3"] = "RemQueryInterface",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@25"] = "LlsrUserProductEnumA",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@16"] = "NetrDfsGetDcAddress",
    ["12345678-1234-abcd-ef00-0123456789ab@44"] = "RpcDeletePrinterConnection",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@12"] = "KeyrEnroll_V2",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@12"] = "PNP_GetDepth",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@55"] = "RpcWinStationQueryLogonCredentials",
    ["12345678-1234-abcd-ef00-0123456789ab@46"] = "RpcAddMonitor",
    ["12345678-1234-abcd-ef00-01234567cffb@37"] = "DsrAddressToSiteNamesExW",
    ["12345678-1234-abcd-ef00-0123456789ab@79"] = "RpcEnumPrinterDataEx",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@63"] = "LlsrReplicationServiceAddW",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@21"] = "PNP_GetInterfaceDeviceAlias",
    ["12345778-1234-abcd-ef00-0123456789ab@41"] = "LsarDeleteTrustedDomain",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@19"] = "LlsrUserInfoGetA",
    ["12345778-1234-abcd-ef00-0123456789ac@18"] = "SamrLookupIdsInDomain",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@17"] = "RpcWinStationShadow",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@47"] = "PNP_AddResDes",
    ["12345678-1234-abcd-ef00-0123456789ab@87"] = "RpcEnumPerMachineConnections",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@44"] = "PNP_GetFirstLogConf",
    ["d95afe70-a6d5-4259-822e-2c84da1ddb0d@1"] = "WsdrAbortShutdown",
    ["99fcfec4-5260-101b-bbcb-00aa0021347a@0"] = "ResolveOxid",
    ["c386ca3e-9061-4a72-821e-498d83be188f@4"] = "AudioServerCreateStream",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@12"] = "CreateClassEnum",
    ["367abb81-9844-35f1-ad32-98f038001003@43"] = "ScSendTSMessage",
    ["12345778-1234-abcd-ef00-0123456789ab@83"] = "LsarSetAuditPolicy",
    ["12345778-1234-abcd-ef00-0123456789ab@50"] = "LsarEnumerateTrustedDomainsEx",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@8"] = "PNP_GetRelatedDeviceInstance",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@1"] = "EcDoDisconnect",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@66"] = "RpcConnectCallback",
    ["c386ca3e-9061-4a72-821e-498d83be188f@66"] = "AudioVolumeStepDown",
    ["367abb81-9844-35f1-ad32-98f038001003@25"] = "EnumDependentServicesA",
    ["12345678-1234-abcd-ef00-0123456789ab@42"] = "RpcDeletePrinterIC",
    ["12345678-1234-abcd-ef00-0123456789ab@50"] = "RpcDeletePrintProvidor",
    ["17fdd703-1827-4e34-79d4-24a55c53bb37@2"] = "NetrMessageNameGetInfo",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@9"] = "NspiGetProps",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@12"] = "R_WinsWorkerThdUpd",
    ["86d35949-83c9-4044-b424-db363231fd0c@7"] = "SchRpcEnumTasks",
    ["f50aac00-c7f3-428e-a022-a6b71bfb9d43@5"] = "SSCatDBRebuildDatabase",
    ["12345678-1234-abcd-ef00-01234567cffb@8"] = "NetrDatabaseSync",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@27"] = "NetrServerTransportDel",
    ["6bffd098-a112-3610-9833-46c3f87e345a@1"] = "NetrWkstaSetInfo",
    ["12345778-1234-abcd-ef00-0123456789ac@41"] = "SamrGetDisplayEnumerationIndex",
    ["12345678-1234-abcd-ef00-0123456789ab@20"] = "RpcEndPagePrinter",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@17"] = "LlsrUserEnumA",
    ["c386ca3e-9061-4a72-821e-498d83be188f@30"] = "AudioServerGetMixFormat",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@7"] = "SfcSrv_InstallProtectedFiles",
    ["367abb81-9844-35f1-ad32-98f038001003@40"] = "QueryServiceStatusEx",
    ["12345678-1234-abcd-ef00-01234567cffb@15"] = "NetrServerAuthenticate2",
    ["367abb81-9844-35f1-ad32-98f038001003@22"] = "ScSetServiceBitsA",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@7"] = "EcRGetDCName",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@32"] = "PNP_DisableDevInst",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@20"] = "RpcWinStationGenerateLicense",
    ["c386ca3e-9061-4a72-821e-498d83be188f@26"] = "AudioSessionGetChannelVolume",
    ["12345778-1234-abcd-ef00-0123456789ac@33"] = "SamrGetMembersInAlias",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@24"] = "ElfrReportEventAndSourceW",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@24"] = "NetrServerStatisticsGet",
    ["12345778-1234-abcd-ef00-0123456789ac@63"] = "SamrUnicodeChangePasswordUser3",
    ["12345778-1234-abcd-ef00-0123456789ab@30"] = "LsarQuerySecret",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@1"] = "DnssrvQuery",
    ["2f5f3220-c126-1076-b549-074d078619da@12"] = "NDdeSetTrustedShareW",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@45"] = "PNP_GetNextLogConf",
    ["86d35949-83c9-4044-b424-db363231fd0c@5"] = "SchRpcGetSecurity",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@10"] = "nsi_profile_elt_inq_next",
    ["12345778-1234-abcd-ef00-0123456789ac@6"] = "SamrEnumerateDomainsInSamServer",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@87"] = "LlsrLocalServiceInfoGetW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@80"] = "LlsrCapabilityGet",
    ["c386ca3e-9061-4a72-821e-498d83be188f@15"] = "AudioSessionIsSystemSoundsSession",
    ["12345778-1234-abcd-ef00-0123456789ab@73"] = "LsarQueryForestTrustInformation",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@5"] = "SfcSrv_SetCacheSize",
    ["12345678-1234-abcd-ef00-0123456789ab@15"] = "RpcEnumPrintProcessors",
    ["12345678-1234-abcd-ef00-0123456789ab@8"] = "RpcGetPrinter",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@8"] = "gfxLogoff",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@3"] = "OpenNamespace",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@63"] = "PNP_GetBlockedDriverInfo",
    ["12345678-1234-abcd-ef00-01234567cffb@18"] = "NetrLogonControl2Ex",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@16"] = "NetrShareGetInfo",
    ["12345778-1234-abcd-ef00-0123456789ab@37"] = "LsarAddAccountRights",
    ["338cd001-2244-31f1-aaaa-900038001003@6"] = "BaseRegCreateKey",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@3"] = "NetrDfsSetInfo",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@9"] = "PNP_EnumerateSubKeys",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@16"] = "RpcSrvGetClassId",
    ["12345778-1234-abcd-ef00-0123456789ac@0"] = "SamrConnect",
    ["c386ca3e-9061-4a72-821e-498d83be188f@58"] = "AudioVolumeAddMasterVolumeNotification",
    ["12345778-1234-abcd-ef00-0123456789ab@71"] = "LsarGenAuditEvent",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@56"] = "PNP_QueryArbitratorFreeData",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@26"] = "LlsrUserProductDeleteW",
    ["12345778-1234-abcd-ef00-0123456789ac@21"] = "SamrSetInformationGroup",
    ["367abb81-9844-35f1-ad32-98f038001003@42"] = "EnumServicesStatusExW",
    ["12345778-1234-abcd-ef00-0123456789ac@61"] = "SamrConnect3",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@55"] = "LlsrServiceInfoGetA",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@14"] = "EcDoAsyncConnectEx",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@4"] = "FrsBackupComplete",
    ["12345678-1234-abcd-ef00-01234567cffb@27"] = "DsrGetDcNameEx",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@37"] = "LlsrMappingUserAddA",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@0"] = "nsi_group_delete",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@51"] = "LlsrLocalProductInfoGetA",
    ["99fcfec4-5260-101b-bbcb-00aa0021347a@2"] = "ComplexPing",
    ["12345678-1234-abcd-ef00-0123456789ab@23"] = "RpcEndDocPrinter",
    ["12345678-1234-abcd-ef00-0123456789ab@60"] = "RpcReplyClosePrinter",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@44"] = "RpcWinStationGetProcessSid",
    ["12345778-1234-abcd-ef00-0123456789ac@5"] = "SamrLookupDomainInSamServer",
    ["c386ca3e-9061-4a72-821e-498d83be188f@8"] = "AudioServerIsFormatSupported",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@5"] = "QueryObjectSink",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@8"] = "RpcAsyncSetPrinter",
    ["12345778-1234-abcd-ef00-0123456789ab@92"] = "CredReadByTokenHandle",
    ["338cd001-2244-31f1-aaaa-900038001003@13"] = "BaseRegLoadKey",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@12"] = "DRSCrackNames",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@18"] = "RpcAsyncSetPrinterData",
    ["12345778-1234-abcd-ef00-0123456789ac@39"] = "SamrGetGroupsForUser",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@15"] = "DRSRemoveDsDomain",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@34"] = "RpcAsyncSendRecvBidiData",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@31"] = "NetprPathCanonicalize",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c3@1"] = "nsi_binding_unexport",
    ["12345778-1234-abcd-ef00-0123456789ab@90"] = "LsarSetAuditSecurity",
    ["00000143-0000-0000-c000-000000000046@5"] = "RemRelease",
    ["12345778-1234-abcd-ef00-0123456789ab@22"] = "LsarSetQuotasForAccount",
    ["12345778-1234-abcd-ef00-0123456789ac@65"] = "SamrRidToSid",
    ["12345778-1234-abcd-ef00-0123456789ab@0"] = "LsarClose",
    ["338cd001-2244-31f1-aaaa-900038001003@30"] = "BaseInitiateSystemShutdownEx",
    ["12345778-1234-abcd-ef00-0123456789ab@58"] = "LsarLookupNames2",
    ["12345778-1234-abcd-ef00-0123456789ac@8"] = "SamrQueryInformationDomain",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@57"] = "NetrShareDelEx",
    ["6bffd098-a112-3610-9833-46c3f87e345a@31"] = "NetrWorkstationResetDfsCache",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@31"] = "PNP_SetDeviceProblem",
    ["12345678-1234-abcd-ef00-0123456789ab@40"] = "RpcCreatePrinterIC",
    ["12345678-1234-abcd-ef00-01234567cffb@30"] = "NetrServerPasswordSet2",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@14"] = "PNP_SetDeviceRegProp",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@6"] = "NetrCharDevQPurge",
    ["12345778-1234-abcd-ef00-0123456789ab@54"] = "LsarSetDomainInformationPolicy",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@15"] = "nsi_entry_expand_name",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@8"] = "RpcLicensingDeactivateCurrentPolicy",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@7"] = "ept_map_auth",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@35"] = "NetprNameCompare",
    ["378e52b0-c0a9-11cf-822d-00aa0051e40f@1"] = "SASetNSAccountInformation",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@24"] = "RpcSrvDeRegisterConnectionStateNotification",
    ["86d35949-83c9-4044-b424-db363231fd0c@9"] = "SchRpcGetInstanceInfo",
    ["367abb81-9844-35f1-ad32-98f038001003@16"] = "OpenServiceW",
    ["338cd001-2244-31f1-aaaa-900038001003@27"] = "OpenCurrentConfig",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@24"] = "ExecMethod",
    ["68b58241-c259-4f03-a2e5-a2651dcbc930@1"] = "KSrGetTemplates",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@53"] = "RpcAsyncDeletePrintProcessor",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@11"] = "RpcSrvRegisterParams",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@9"] = "RpcWinStationNameFromLogonId",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@19"] = "RpcAsyncSetPrinterDataEx",
    ["12345678-1234-abcd-ef00-0123456789ab@2"] = "RpcSetJob",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@25"] = "ExecMethodAsync",
    ["afa8bd80-7d8a-11c9-bef4-08002b102989@2"] = "is_server_listening",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@8"] = "R_WinsDelDbRecs",
    ["6bffd098-a112-3610-9833-012892020162@3"] = "BrowserrResetNetlogonState",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@1"] = "LlsrClose",
    ["12345678-1234-abcd-ef00-01234567cffb@29"] = "NetrLogonGetDomainInfo",
    ["367abb81-9844-35f1-ad32-98f038001003@24"] = "CreateServiceA",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@7"] = "RpcWinStationSendMessage",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@10"] = "KeyrEnumerateAvailableCertTypes",
    ["12345678-1234-abcd-ef00-0123456789ab@59"] = "RpcRouterReplyPrinter",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@57"] = "PNP_QueryArbitratorFreeSize",
    ["378e52b0-c0a9-11cf-822d-00aa0051e40f@0"] = "SASetAccountInformation",
    ["12345678-1234-abcd-ef00-0123456789ab@43"] = "RpcAddPrinterConnection",
    ["12345678-1234-abcd-ef00-0123456789ab@16"] = "RpcGetPrintProcessorDirectory",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@14"] = "NetrDfsManagerInitialize",
    ["6bffd098-a112-3610-9833-46c3f87e345a@11"] = "NetrUseEnum",
    ["12345778-1234-abcd-ef00-0123456789ac@11"] = "SamrEnumerateGroupsInDomain",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@26"] = "RpcWinStationSetPoolCount",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@29"] = "PNP_DeviceInstanceAction",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@53"] = "RpcWinStationGetLanAdapterName",
    ["c386ca3e-9061-4a72-821e-498d83be188f@53"] = "AudioVolumeSetChannelVolumeLevelScalar",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@6"] = "DnssrvQuery2",
    ["6bffd098-a112-3610-9833-012892020162@6"] = "BrowserrResetStatistics",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@22"] = "RpcSrvRequestCachedParams",
    ["12345778-1234-abcd-ef00-0123456789ab@15"] = "LsarLookupSids",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@6"] = "NetrDfsRename",
    ["6bffd098-a112-3610-9833-46c3f87e345a@15"] = "NetrLogonDomainNameDel",
    ["12345678-1234-abcd-ef00-0123456789ab@0"] = "RpcEnumPrinters",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@9"] = "DnssrvUpdateRecord2",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@12"] = "NetrDfsAddStdRoot",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@0"] = "RpcWinStationOpenServer",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@1"] = "RpcAsyncAddPrinter",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@13"] = "EcUnknown0xD",
    ["367abb81-9844-35f1-ad32-98f038001003@32"] = "GetServiceDisplayNameA",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@37"] = "RpcAsyncDeletePrinterIC",
    ["c386ca3e-9061-4a72-821e-498d83be188f@16"] = "AudioSessionGetDisplayName",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@76"] = "LlsrCertificateClaimAddW",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c3@0"] = "nsi_binding_export",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@22"] = "LlsrUserDeleteW",
    ["894de0c0-0d55-11d3-a322-00c04fa321a1@0"] = "BaseInitiateShutdown",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@6"] = "SfcSrv_SetDisable",
    ["12345678-1234-abcd-ef00-01234567cffb@39"] = "NetrLogonSamLogonEx",
    ["338cd001-2244-31f1-aaaa-900038001003@23"] = "BaseRegUnLoadKey",
    ["12345678-1234-abcd-ef00-0123456789ab@30"] = "RpcAddForm",
    ["c386ca3e-9061-4a72-821e-498d83be188f@5"] = "AudioServerDestroyStream",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@35"] = "RpcAsyncCreatePrinterIC",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@65"] = "LlsrProductSecurityGetW",
    ["c386ca3e-9061-4a72-821e-498d83be188f@57"] = "AudioSessionGetDisplayName",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@67"] = "RpcAsyncDeletePrinterDriverPackage",
    ["f50aac00-c7f3-428e-a022-a6b71bfb9d43@0"] = "SSCatDBAddCatalog",
    ["367abb81-9844-35f1-ad32-98f038001003@52"] = "ScSendPnPMessage",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@64"] = "RpcAsyncGetCorePrinterDrivers",
    ["12345678-1234-abcd-ef00-0123456789ab@100"] = "RpcUploadPrinterDriverPackage",
    ["12345778-1234-abcd-ef00-0123456789ab@25"] = "LsarOpenTrustedDomain",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@73"] = "RpcWinStationAutoReconnect",
    ["12345678-1234-abcd-ef00-0123456789ab@3"] = "RpcGetJob",
    ["12345778-1234-abcd-ef00-0123456789ab@67"] = "CredrProfileLoaded",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@39"] = "RpcAsyncAddPrinterDriver",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@30"] = "NetprPathType",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@10"] = "LlsrProductUserEnumW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@33"] = "LlsrMappingInfoSetA",
    ["12345778-1234-abcd-ef00-0123456789ab@93"] = "CredrRestoreCredentials",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@44"] = "RpcAsyncAddPrintProcessor",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@2"] = "RpcIcaServerPing",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@38"] = "LlsrMappingUserDeleteW",
    ["338cd001-2244-31f1-aaaa-900038001003@16"] = "BaseRegQueryInfoKey",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@52"] = "LlsrLocalProductInfoSetW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@71"] = "LlsrCertificateClaimEnumA",
    ["2f5f3220-c126-1076-b549-074d078619da@18"] = "NDdeSpecialCommand",
    ["367abb81-9844-35f1-ad32-98f038001003@28"] = "OpenServiceA",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@53"] = "NetrServerTransportDelEx",
    ["c386ca3e-9061-4a72-821e-498d83be188f@32"] = "PolicyConfigSetDeviceFormat",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@29"] = "LlsrMappingEnumA",
    ["c386ca3e-9061-4a72-821e-498d83be188f@31"] = "PolicyConfigGetDeviceFormat",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@71"] = "PNP_DriverStoreDeleteDriverPackage",
    ["338cd001-2244-31f1-aaaa-900038001003@8"] = "BaseRegDeleteValue",
    ["12345678-1234-abcd-ef00-01234567cffb@3"] = "NetrLogonSamLogoff",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@3"] = "nsi_group_mbr_inq_begin",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@79"] = "LlsrReplicationUserAddExW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@86"] = "LlsrLocalServiceInfoSetA",
    ["12345678-1234-abcd-ef00-0123456789ab@27"] = "RpcSetPrinterData",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@8"] = "DnssrvEnumRecords2",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@17"] = "RpcSrvSetClientId",
    ["12345778-1234-abcd-ef00-0123456789ab@62"] = "CredrEnumerate",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@69"] = "LlsrProductLicensesGetA",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@18"] = "LlsrUserInfoGetW",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@14"] = "R_WinsGetBrowserNames_Old",
    ["12345678-1234-abcd-ef00-0123456789ab@67"] = "RpcRouterRefreshPrinterChangeNotification",
    ["12345678-1234-abcd-ef00-0123456789ab@6"] = "RpcDeletePrinter",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@61"] = "RpcWinStationIsHelpAssistantSession",
    ["12345778-1234-abcd-ef00-0123456789ab@44"] = "LsarOpenPolicy2",
    ["367abb81-9844-35f1-ad32-98f038001003@3"] = "LockServiceDatabase",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@38"] = "NetrShareDelCommit",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@46"] = "PNP_GetLogConfPriority",
    ["12345678-1234-abcd-ef00-0123456789ab@56"] = "RpcFindClosePrinterChangeNotification",
    ["367abb81-9844-35f1-ad32-98f038001003@54"] = "ScOpenServiceStatusHandle",
    ["338cd001-2244-31f1-aaaa-900038001003@26"] = "BaseRegGetVersion",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@12"] = "ElfrClearELFA",
    ["6bffd098-a112-3610-9833-46c3f87e345a@24"] = "NetrRenameMachineInDomain2",
    ["12345778-1234-abcd-ef00-0123456789ab@5"] = "LsarChangePassword",
    ["12345678-1234-abcd-ef00-01234567cffb@10"] = "NetrAccountSync",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@18"] = "CreateInstanceEnum",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@42"] = "LlsrMappingDeleteW",
    ["f50aac00-c7f3-428e-a022-a6b71bfb9d43@3"] = "SSCatDBRegisterForChangeNotification",
    ["12b81e99-f207-4a4c-85d3-77b42f76fd14@0"] = "SeclCreateProcessWithLogonW",
    ["2f5f3220-c126-1076-b549-074d078619da@4"] = "NDdeGetShareSecurityW",
    ["12345678-1234-abcd-ef00-01234567cffb@36"] = "NetrEnumerateTrustedDomainsEx",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@19"] = "NetrDfsAdd2",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@3"] = "R_WinsDoStaticInit",
    ["338cd001-2244-31f1-aaaa-900038001003@3"] = "OpenPerformanceData",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@52"] = "RpcServerQueryInetConnectorInformation",
    ["12345678-1234-abcd-ef00-01234567cffb@13"] = "NetrGetAnyDCName",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@8"] = "DsRolerServerSaveStateForUpgrade",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@9"] = "ElfrOpenBELW",
    ["338cd001-2244-31f1-aaaa-900038001003@34"] = "BaseRegQueryMultipleValues2",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@58"] = "PNP_RunDetection",
    ["367abb81-9844-35f1-ad32-98f038001003@11"] = "ChangeServiceConfigW",
    ["12345778-1234-abcd-ef00-0123456789ac@1"] = "SamrCloseHandle",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@41"] = "PNP_GetHwProfInfo",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@40"] = "PNP_HwProfFlags",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@12"] = "NetrSessionEnum",
    ["000001a0-0000-0000-c000-000000000046@3"] = "RemoteGetClassObject",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@28"] = "RpcWinStationCallback",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@5"] = "LlsrLicenseAddA",
    ["17fdd703-1827-4e34-79d4-24a55c53bb37@3"] = "NetrMessageNameDel",
    ["12345678-1234-abcd-ef00-0123456789ab@22"] = "RpcReadPrinter",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@18"] = "DRSExecuteKCC",
    ["12345778-1234-abcd-ef00-0123456789ab@87"] = "LsarEnumerateAuditSubCategories",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@33"] = "RpcAsyncXcvData",
    ["c386ca3e-9061-4a72-821e-498d83be188f@21"] = "AudioSessionSetVolume",
    ["367abb81-9844-35f1-ad32-98f038001003@44"] = "CreateServiceWOW64A",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@2"] = "ElfrCloseEL",
    ["12345678-1234-abcd-ef00-01234567cffb@24"] = "NetrLogonComputeServerDigest",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@40"] = "RpcWinStationNtsdDebug",
    ["12345678-1234-abcd-ef00-01234567cffb@35"] = "NetrLogonGetTimeServiceParentDomain",
    ["c386ca3e-9061-4a72-821e-498d83be188f@27"] = "AudioSessionSetAllVolumes",
    ["12345778-1234-abcd-ef00-0123456789ab@94"] = "CredrBackupCredentials",
    ["6bffd098-a112-3610-9833-46c3f87e345a@29"] = "NetrSetPrimaryComputerName",
    ["367abb81-9844-35f1-ad32-98f038001003@48"] = "GetNotifyResult",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@0"] = "SfcSrv_GetNextProtectedFile",
    ["68b58241-c259-4f03-a2e5-a2651dcbc930@0"] = "KSrSubmitRequest",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@70"] = "LlsrProductLicensesGetW",
    ["12345778-1234-abcd-ef00-0123456789ab@14"] = "LsarLookupNames",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@1"] = "ElfrBackupELFW",
    ["12345778-1234-abcd-ef00-0123456789ac@54"] = "SamrOemChangePasswordUser2",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@2"] = "LlsrLicenseEnumW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@44"] = "LlsrServerEnumW",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@9"] = "KeyrImportCert",
    ["91ae6020-9e3c-11cf-8d7c-00aa00c091be@0"] = "CertServerRequest",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@45"] = "NetrDfsDeleteLocalPartition",
    ["c386ca3e-9061-4a72-821e-498d83be188f@45"] = "AudioVolumeConnect",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@21"] = "RpcWinStationInstallLicense",
    ["c386ca3e-9061-4a72-821e-498d83be188f@43"] = "AudioSessionManagerDeleteAudioSessionClientNotification",
    ["12345678-1234-abcd-ef00-0123456789ab@47"] = "RpcDeleteMonitor",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@70"] = "PNP_DriverStoreAddDriverPackage",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@5"] = "RpcLicensingGetAvailablePolicyIds",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@9"] = "FrsBackupComplete",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@39"] = "PNP_RequestEjectPC",
    ["6bffd098-a112-3610-9833-46c3f87e345a@19"] = "NetrRenameMachineInDomain",
    ["12345678-1234-abcd-ef00-01234567cffb@20"] = "DsrGetDcName",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@18"] = "RpcWinStationShadowTargetSetup",
    ["1ff70682-0a51-30e8-076d-740be8cee98b@3"] = "NetrJobGetInfo",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@11"] = "ElfrReportEventW",
    ["12345678-1234-abcd-ef00-0123456789ab@39"] = "RpcDeletePort",
    ["12345778-1234-abcd-ef00-0123456789ac@29"] = "SamrSetInformationAlias",
    ["86d35949-83c9-4044-b424-db363231fd0c@6"] = "SchRpcEnumFolder",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@43"] = "RpcAsyncDeletePrinterDriverEx",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@9"] = "LlsrProductAddA",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@28"] = "LlsrMappingEnumW",
    ["12345778-1234-abcd-ef00-0123456789ab@12"] = "LsarCreateTrustedDomain",
    ["12345778-1234-abcd-ef00-0123456789ac@3"] = "SamrQuerySecurityObject",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@14"] = "LlsrProductLicenseEnumW",
    ["12345778-1234-abcd-ef00-0123456789ab@66"] = "CredrGetTargetInfo",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@29"] = "RpcWinStationGetApplicationInfo",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@24"] = "RpcAsyncSetForm",
    ["c386ca3e-9061-4a72-821e-498d83be188f@22"] = "AudioSessionGetMute",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@0"] = "R_WinsRecordAction",
    ["6bffd098-a112-3610-9833-012892020162@7"] = "NetrBrowserStatisticsClear",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@0"] = "ElfrClearELFW",
    ["12345778-1234-abcd-ef00-0123456789ab@45"] = "LsarGetUserName",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@30"] = "PNP_GetDeviceStatus",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@6"] = "RpcLicensingGetPolicy",
    ["12345778-1234-abcd-ef00-0123456789ab@19"] = "LsarAddPrivilegesToAccount",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@41"] = "NetrServerTransportAddEx",
    ["12345778-1234-abcd-ef00-0123456789ab@51"] = "LsarCreateTrustedDomainEx",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@1"] = "KeyrEnumerateProviders",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@10"] = "FrsRpcVerifyPromotionParentEx",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@41"] = "RpcWinStationBreakPoint",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@15"] = "PNP_GetClassInstance",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@50"] = "PNP_GetResDesData",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@10"] = "PNP_GetDeviceList",
    ["12345778-1234-abcd-ef00-0123456789ac@37"] = "SamrSetInformationUser",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@19"] = "RpcSrvNotifyMediaReconnected",
    ["338cd001-2244-31f1-aaaa-900038001003@29"] = "BaseRegQueryMultipleValues",
    ["86d35949-83c9-4044-b424-db363231fd0c@4"] = "SchRpcSetSecurity",
    ["12345778-1234-abcd-ef00-0123456789ab@39"] = "LsarQueryTrustedDomainInfo",
    ["12345678-1234-abcd-ef00-01234567cffb@1"] = "NetrLogonUasLogoff",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@75"] = "RpcWinStationOpenSessionDirectory",
    ["afa8bd80-7d8a-11c9-bef4-08002b102989@1"] = "inq_stats",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@26"] = "PNP_GetClassRegProp",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@19"] = "PNP_GetClassName",
    ["6bffd098-a112-3610-9833-46c3f87e345a@9"] = "NetrUseGetInfo",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@7"] = "DRSReplicaModify",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@33"] = "RpcWinStationNotifyLogoff",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@58"] = "RpcWinStationUpdateSettings",
    ["12345778-1234-abcd-ef00-0123456789ab@49"] = "LsarSetTrustedDomainInfoByName",
    ["00000143-0000-0000-c000-000000000046@1"] = "AddRef",
    ["6bffd098-a112-3610-9833-012892020162@11"] = "BrowserrServerEnumEx",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@84"] = "LlsrLocalServiceAddW",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@6"] = "FrsBackupComplete",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@32"] = "NetprPathCompare",
    ["12345678-1234-abcd-ef00-0123456789ab@65"] = "RpcRemoteFindFirstPrinterChangeNotificationEx",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@69"] = "PNP_ApplyPowerSettings",
    ["12345778-1234-abcd-ef00-0123456789ab@85"] = "LsarEnumerateAuditPolicy",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@6"] = "NspiResortRestriction",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@5"] = "DRSReplicaAdd",
    ["afa8bd80-7d8a-11c9-bef4-08002b102989@4"] = "inq_princ_name",
    ["12345678-1234-abcd-ef00-0123456789ab@36"] = "RpcEnumMonitors",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@1"] = "FrsRpcVerifyPromotionParent",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@32"] = "RpcWinStationNotifyLogon",
    ["12345678-1234-abcd-ef00-0123456789ab@1"] = "RpcOpenPrinter",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@67"] = "LlsrProductSecuritySetW",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@10"] = "RpcSrvPersistentRequestParams",
    ["f309ad18-d86a-11d0-a075-00c04fb68820@4"] = "RequestChallenge",
    ["c386ca3e-9061-4a72-821e-498d83be188f@29"] = "AudioServerDisconnect",
    ["c386ca3e-9061-4a72-821e-498d83be188f@34"] = "PolicyConfigSetProcessingPeriod",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@13"] = "LlsrProductServerEnumA",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@6"] = "nsi_profile_delete",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@2"] = "PNP_GetVersion",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@68"] = "RpcWinStationSessionInitialized",
    ["12345678-1234-abcd-ef00-0123456789ab@95"] = "RpcSendRecvBidiData",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@27"] = "RpcAsyncEnumPrinterData",
    ["c386ca3e-9061-4a72-821e-498d83be188f@18"] = "AudioSessionGetSessionClass",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@16"] = "PNP_CreateKey",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@12"] = "LlsrProductServerEnumW",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@33"] = "PNP_UninstallDevInst",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@72"] = "RpcAsyncDeleteJobNamedProperty",
    ["338cd001-2244-31f1-aaaa-900038001003@9"] = "BaseRegEnumKey",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@43"] = "PNP_FreeLogConf",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@19"] = "NetrShareDelSticky",
    ["367abb81-9844-35f1-ad32-98f038001003@23"] = "ChangeServiceConfigA",
    ["12345778-1234-abcd-ef00-0123456789ac@24"] = "SamrRemoveMemberFromGroup",
    ["2f5f3220-c126-1076-b549-074d078619da@6"] = "NDdeSetShareSecurityW",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@1"] = "R_WinsStatus",
    ["6bffd098-a112-3610-9833-012892020162@10"] = "BrowserrQueryEmulatedDomains",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@34"] = "RpcWinStationEnumerateProcesses",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@11"] = "RpcAsyncStartPagePrinter",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@69"] = "RpcAsyncResetPrinter",
    ["367abb81-9844-35f1-ad32-98f038001003@0"] = "CloseServiceHandle",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@14"] = "nsi_entry_object_inq_done",
    ["12345778-1234-abcd-ef00-0123456789ac@55"] = "SamrUnicodeChangePasswordUser2",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@46"] = "RpcAsyncGetPrintProcessorDirectory",
    ["c386ca3e-9061-4a72-821e-498d83be188f@49"] = "AudioVolumeSetMasterVolumeLevelScalar",
    ["338cd001-2244-31f1-aaaa-900038001003@33"] = "OpenPerformanceNlsText",
    ["367abb81-9844-35f1-ad32-98f038001003@7"] = "SetServiceStatus",
    ["c386ca3e-9061-4a72-821e-498d83be188f@52"] = "AudioVolumeSetChannelVolumeLevel",
    ["57674cd0-5200-11ce-a897-08002b2e9c6d@1"] = "LlsrLicenseFree",
    ["17fdd703-1827-4e34-79d4-24a55c53bb37@1"] = "NetrMessageNameEnum",
    ["12345678-1234-abcd-ef00-01234567cffb@44"] = "NetrGetForestTrustInformation",
    ["12345678-1234-abcd-ef00-0123456789ab@25"] = "RpcScheduleJob",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@11"] = "winmmSessionConnectState",
    ["12345778-1234-abcd-ef00-0123456789ab@88"] = "LsarLookupAuditCategoryName",
    ["12345678-1234-abcd-ef00-0123456789ab@75"] = "RpcClusterSplClose",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@18"] = "ElfrReportEventA",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@2"] = "EcDoRpc",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@16"] = "ElfrOpenBELA",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@0"] = "DsRolerGetPrimaryDomainInformation",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@18"] = "PNP_GetClassCount",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@21"] = "LlsrUserInfoSetA",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@17"] = "NetrShareSetInfo",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@1"] = "SfcSrv_IsFileProtected",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@71"] = "RpcAsyncSetJobNamedProperty",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@4"] = "PNP_InitDetection",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@63"] = "RpcWinStationUpdateClientCachedCredentials",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@4"] = "DsRolerDemoteDc",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@0"] = "DnssrvOperation",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@23"] = "NetrServerDiskEnum",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@49"] = "LlsrLocalProductEnumA",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@31"] = "LlsrMappingInfoGetA",
    ["3dde7c30-165d-11d1-ab8f-00805f14db40@0"] = "bkrp_BackupKey",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@4"] = "EcRRegisterPushNotification",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@61"] = "RpcAsyncGetRemoteNotifications",
    ["57674cd0-5200-11ce-a897-08002b2e9c6d@0"] = "LlsrLicenseRequestW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@83"] = "LlsrLocalServiceAddA",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@10"] = "DRSInterDomainMove",
    ["c386ca3e-9061-4a72-821e-498d83be188f@59"] = "AudioVolumeDeleteMasterVolumeNotification",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@1"] = "NetrCharDevGetInfo",
    ["0a74ef1c-41a4-4e06-83ae-dc74fb1cdd53@1"] = "ItSrvUnregisterIdleTask",
    ["000001a0-0000-0000-c000-000000000046@2"] = "ReleaseIRemoteISCMActivator",
    ["12345678-1234-abcd-ef00-01234567cffb@41"] = "DsrDeregisterDnsHostRecords",
    ["12345778-1234-abcd-ef00-0123456789ab@33"] = "LsarLookupPrivilegeDisplayName",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@36"] = "RpcAsyncPlayGdiScriptOnPrinterIC",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@39"] = "RpcServerNWLogonQueryAdmin",
    ["c386ca3e-9061-4a72-821e-498d83be188f@55"] = "AudioVolumeGetChannelVolumeLevelScalar",
    ["12345678-1234-abcd-ef00-0123456789ab@96"] = "RpcAddDriverCatalog",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@4"] = "CancelAsyncCall",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@63"] = "RpcAsyncUploadPrinterDriverPackage",
    ["12345678-1234-abcd-ef00-0123456789ab@97"] = "RpcAddPrinterConnection2",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@11"] = "PNP_GetDeviceListSize",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@65"] = "RpcAsyncCorePrinterDriverInstalled",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@25"] = "PNP_UnregisterDeviceClassAssociation",
    ["c386ca3e-9061-4a72-821e-498d83be188f@3"] = "AudioServerGetAudioSession",
    ["12345778-1234-abcd-ef00-0123456789ac@27"] = "SamrOpenAlias",
    ["d3fbb514-0e3b-11cb-8fad-08002b1d29c3@0"] = "nsi_binding_lookup_begin",
    ["12345678-1234-abcd-ef00-0123456789ab@9"] = "RpcAddPrinterDriver",
    ["367abb81-9844-35f1-ad32-98f038001003@41"] = "EnumServicesStatusExA",
    ["2f5f3220-c126-1076-b549-074d078619da@5"] = "NDdeSetShareSecurityA",
    ["6bffd098-a112-3610-9833-46c3f87e345a@22"] = "NetrJoinDomain2",
    ["12345778-1234-abcd-ef00-0123456789ac@59"] = "SamrSetBootKeyInformation",
    ["12345778-1234-abcd-ef00-0123456789ac@45"] = "SamrRemoveMemberFromForeignDomain",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@9"] = "NetrDfsManagerSendSiteInfo",
    ["367abb81-9844-35f1-ad32-98f038001003@45"] = "CreateServiceWOW64W",
    ["12345678-1234-abcd-ef00-01234567cffb@21"] = "NetrLogonGetCapabilities",
    ["12345778-1234-abcd-ef00-0123456789ab@81"] = "LsarAdtReportSecurityEvent",
    ["12345678-1234-abcd-ef00-0123456789ab@71"] = "RpcSetPort",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@13"] = "RpcWinStationDisconnect",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@23"] = "LlsrUserDeleteA",
    ["12345778-1234-abcd-ef00-0123456789ac@7"] = "SamrOpenDomain",
    ["c386ca3e-9061-4a72-821e-498d83be188f@25"] = "AudioSessionSetChannelVolume",
    ["338cd001-2244-31f1-aaaa-900038001003@28"] = "OpenDynData",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@17"] = "ElfrReadELA",
    ["367abb81-9844-35f1-ad32-98f038001003@2"] = "DeleteService",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@55"] = "PNP_SetHwProf",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@2"] = "nsi_group_mbr_remove",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@22"] = "RpcWinStationEnumerateLicenses",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@72"] = "PNP_RegisterServiceNotification",
    ["12345678-1234-abcd-ef00-0123456789ab@32"] = "RpcGetForm",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@42"] = "PNP_AddEmptyLogConf",
    ["6bffd098-a112-3610-9833-46c3f87e345a@4"] = "NetrWkstaUserSetInfo",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@3"] = "LlsrLicenseEnumA",
    ["86d35949-83c9-4044-b424-db363231fd0c@17"] = "SchRpcGetTaskInfo",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@3"] = "EcGetMoreRpc",
    ["12345678-1234-abcd-ef00-0123456789ab@82"] = "RpcDeletePrinterKey",
    ["000001a0-0000-0000-c000-000000000046@4"] = "RemoteCreateInstance",
    ["12345778-1234-abcd-ef00-0123456789ab@1"] = "LsarDelete",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@32"] = "RpcAsyncDeletePrinterKey",
    ["12345778-1234-abcd-ef00-0123456789ab@76"] = "LsarLookupSids3",
    ["12345778-1234-abcd-ef00-0123456789ac@69"] = "SamrPerformGenericOperation",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@11"] = "R_WinsResetCounters",
    ["12345778-1234-abcd-ef00-0123456789ac@36"] = "SamrQueryInformationUser",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@2"] = "DsRolerDcAsDc",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@48"] = "LlsrLocalProductEnumW",
    ["12345778-1234-abcd-ef00-0123456789ab@61"] = "CredrRead",
    ["f50aac00-c7f3-428e-a022-a6b71bfb9d43@4"] = "KeyrCloseKeyService",
    ["12345778-1234-abcd-ef00-0123456789ab@8"] = "LsarSetInformationPolicy",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@39"] = "LlsrMappingUserDeleteA",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@2"] = "ept_lookup",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@21"] = "ElfrWriteClusterEvents",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@74"] = "PNP_DeleteServiceDevices",
    ["12345678-1234-abcd-ef00-01234567cffb@45"] = "NetrLogonSameLogonWithFlags",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@19"] = "ElfrRegisterClusterSvc",
    ["86d35949-83c9-4044-b424-db363231fd0c@12"] = "SchRpcRun",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@1"] = "DRSUnbind",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@41"] = "RpcAsyncGetPrinterDriverDirectory",
    ["c386ca3e-9061-4a72-821e-498d83be188f@36"] = "PolicyConfigSetShareMode",
    ["12345678-1234-abcd-ef00-01234567cffb@48"] = "DsrUpdateReadOnlyServerDnsRecords",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@16"] = "R_WinsSetFlags",
    ["12345778-1234-abcd-ef00-0123456789ab@26"] = "LsarQueryInfoTrustedDomain",
    ["12345778-1234-abcd-ef00-0123456789ab@53"] = "LsarQueryDomainInformationPolicy",
    ["12345678-1234-abcd-ef00-01234567cffb@7"] = "NetrDatabaseDeltas",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@51"] = "RpcServerSetInternetConnectorStatus",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@21"] = "RpcSrvSetMSFTVendorSpecificOptions",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@57"] = "RpcWinStationUnRegisterConsoleNotification",
    ["367abb81-9844-35f1-ad32-98f038001003@4"] = "QueryServiceObjectSecurity",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@26"] = "RpcAsyncGetPrinterDriver",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@81"] = "LlsrLocalServiceEnumW",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@4"] = "DRSUpdateRefs",
    ["12345678-1234-abcd-ef00-0123456789ab@81"] = "RpcDeletePrinterDataEx",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@17"] = "PNP_DeleteRegistryKey",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@6"] = "LlsrProductEnumW",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@3"] = "PNP_GetGlobalState",
    ["1ff70682-0a51-30e8-076d-740be8cee98b@2"] = "NetrJobEnum",
    ["12345778-1234-abcd-ef00-0123456789ab@77"] = "LsarLookupNames4",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@51"] = "NetrDfsFixLocalVolume",
    ["12345778-1234-abcd-ef00-0123456789ac@68"] = "SamrQueryLocalizableAccountsInDomain",
    ["12345678-1234-abcd-ef00-01234567cffb@26"] = "NetrServerAuthenticate3",
    ["d3fbb514-0e3b-11cb-8fad-08002b1d29c3@1"] = "nsi_binding_lookup_done",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@71"] = "RpcWinStationRegisterNotificationEvent",
    ["12345678-1234-abcd-ef00-0123456789ab@68"] = "RpcSetAllocFailCount",
    ["6bffd098-a112-3610-9833-012892020162@8"] = "NetrBrowserStatisticsGet",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@49"] = "NetrDfsDeleteExitPoint",
    ["12345678-1234-abcd-ef00-0123456789ab@70"] = "RpcAddPrinterEx",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@52"] = "PNP_ModifyResDes",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@40"] = "NetrpSetFileSecurity",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@22"] = "NetrDfsSetInfo2",
    ["12345778-1234-abcd-ef00-0123456789ab@79"] = "LsarAdtRegisterSecurityEventSource",
    ["12345678-1234-abcd-ef00-0123456789ab@94"] = "RpcFlushPrinter",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@68"] = "PNP_InstallDevInst",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@16"] = "DRSDomainControllerInfo",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@17"] = "DeleteClassAsync",
    ["367abb81-9844-35f1-ad32-98f038001003@38"] = "QueryServiceConfig2A",
    ["367abb81-9844-35f1-ad32-98f038001003@46"] = "ScQueryServiceTagInfo",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@15"] = "RpcSrvSetClassId",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@58"] = "RpcSyncRegisterForRemoteNotifications",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@5"] = "RpcAsyncAddJob",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@4"] = "LlsrLicenseAddW",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@16"] = "RpcWinStationWaitSystemEvent",
    ["12345778-1234-abcd-ef00-0123456789ac@9"] = "SamrSetInformationDomain",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@9"] = "winmmRegisterSessionNotificationEvent",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@23"] = "PNP_GetInterfaceDeviceListSize",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@14"] = "PutInstance",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@29"] = "RpcAsyncEnumPrinterKey",
    ["12345678-1234-abcd-ef00-0123456789ab@99"] = "RpcInstallPrinterDriverFromPackage",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@74"] = "RpcAsyncLogJobInfoForBranchOffice",
    ["367abb81-9844-35f1-ad32-98f038001003@14"] = "EnumServicesStatusW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@15"] = "LlsrProductLicenseEnumA",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@11"] = "DeleteClassAsync",
    ["4d9f4ab8-7d1c-11cf-861e-0020af6e7c57@0"] = "RemoteActivation",
    ["12345678-1234-abcd-ef00-0123456789ab@12"] = "RpcGetPrinterDriverDirectory",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@46"] = "NetrDfsSetLocalVolumeState",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@9"] = "PutClassAsync",
    ["6bffd098-a112-3610-9833-46c3f87e345a@23"] = "NetrUnjoinDomain2",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@8"] = "NspiGetPropList",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@0"] = "RpcAsyncOpenPrinter",
    ["2f5f3220-c126-1076-b549-074d078619da@15"] = "NDdeTrustedShareEnumA",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@60"] = "PNP_UnregisterNotification",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@45"] = "LlsrServerEnumA",
    ["6bffd098-a112-3610-9833-46c3f87e345a@5"] = "NetrWkstaTransportEnum",
    ["338cd001-2244-31f1-aaaa-900038001003@11"] = "BaseRegFlushKey",
    ["12345678-1234-abcd-ef00-01234567cffb@47"] = "unused",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@56"] = "NetrServerAliasDel",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@60"] = "RpcWinStationCloseServerEx",
    ["12345778-1234-abcd-ef00-0123456789ac@17"] = "SamrLookupNamesInDomain",
    ["1ff70682-0a51-30e8-076d-740be8cee98b@1"] = "NetrJobDel",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@5"] = "FrsBackupComplete",
    ["367abb81-9844-35f1-ad32-98f038001003@9"] = "NotifyBootConfigStatus",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@53"] = "PNP_DetectResourceConflict",
    ["6bffd098-a112-3610-9833-012892020162@5"] = "BrowserrQueryStatistics",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@20"] = "ExecQuery",
    ["c386ca3e-9061-4a72-821e-498d83be188f@51"] = "AudioVolumeGetMasterVolumeLevelScalar",
    ["6bffd098-a112-3610-9833-46c3f87e345a@14"] = "NetrLogonDomainNameAdd",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@74"] = "RpcWinStationCheckAccess",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@3"] = "RpcAsyncGetJob",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@35"] = "RpcWinStationAnnoyancePopup",
    ["6bffd098-a112-3610-9833-46c3f87e345a@26"] = "NetrGetJoinableOUs2",
    ["f309ad18-d86a-11d0-a075-00c04fb68820@6"] = "NTLMLogin",
    ["c386ca3e-9061-4a72-821e-498d83be188f@64"] = "AudioVolumeGetStepInfo",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@35"] = "PNP_RegisterDriver",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@4"] = "ElfrNumberOfRecords",
    ["12345678-1234-abcd-ef00-0123456789ab@33"] = "RpcSetForm",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@4"] = "RpcWinStationRename",
    ["afa8bd80-7d8a-11c9-bef4-08002b102989@0"] = "inq_if_ids",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@3"] = "KeyrEnumerateProvContainers",
    ["c386ca3e-9061-4a72-821e-498d83be188f@42"] = "AudioSessionManagerAddAudioSessionClientNotification",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@64"] = "LlsrReplicationUserAddW",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@4"] = "NetrCharDevQGetInfo",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@46"] = "RpcWinStationReInitializeSecurity",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@52"] = "NetrDfsManagerReportSiteInfo",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@5"] = "PNP_ReportLogOn",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@49"] = "PNP_GetNextResDes",
    ["2f5f3220-c126-1076-b549-074d078619da@16"] = "NDdeTrustedShareEnumW",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@24"] = "RpcWinStationRemoveLicense",
    ["338cd001-2244-31f1-aaaa-900038001003@18"] = "BaseRegReplaceKey",
    ["367abb81-9844-35f1-ad32-98f038001003@20"] = "GetServiceDisplayNameW",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@8"] = "KeyrExportCert",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@2"] = "RpcSrvRenewLeaseByBroadcast",
    ["6bffd098-a112-3610-9833-012892020162@1"] = "BrowserrDebugCall",
    ["12345778-1234-abcd-ef00-0123456789ab@40"] = "LsarSetTrustedDomainInfo",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@14"] = "ElfrOpenELA",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@0"] = "LlsrConnect",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@7"] = "GetObjectAsync",
    ["12345778-1234-abcd-ef00-0123456789ab@24"] = "LsarSetSystemAccessAccount",
    ["12345678-1234-abcd-ef00-0123456789ab@84"] = "RpcDeletePrinterDriverEx",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@62"] = "RpcWinStationGetMachinePolicy",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@7"] = "DnssrvComplexOperation2",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@54"] = "RpcAsyncEnumPrintProcessorDatatypes",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@5"] = "NspiGetMatches",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@17"] = "nsi_mgmt_entry_delete",
    ["367abb81-9844-35f1-ad32-98f038001003@18"] = "QueryServiceLockStatusW",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@16"] = "RpcAsyncGetPrinterData",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@13"] = "KeyrQueryRequestStatus",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@6"] = "GetObject",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@59"] = "PNP_RegisterNotification",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@62"] = "PNP_GetVersionInternal",
    ["12345778-1234-abcd-ef00-0123456789ab@18"] = "LsarEnumeratePrivilegesAccount",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@15"] = "PutInstanceAsync",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@20"] = "RpcAsyncClosePrinter",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@6"] = "EcDummyRpc",
    ["12345678-1234-abcd-ef00-01234567cffb@38"] = "DsrGetDcSiteCoverageW",
    ["12345778-1234-abcd-ef00-0123456789ab@59"] = "LsarCreateTrustedDomainEx2",
    ["12345678-1234-abcd-ef00-01234567cffb@34"] = "DsrGetDcNameEx2",
    ["6bffd098-a112-3610-9833-46c3f87e345a@28"] = "NetrRemoveAlternateComputerName",
    ["c386ca3e-9061-4a72-821e-498d83be188f@50"] = "AudioVolumeGetMasterVolumeLevel",
    ["12345778-1234-abcd-ef00-0123456789ab@7"] = "LsarQueryInformationPolicy",
    ["12345778-1234-abcd-ef00-0123456789ac@30"] = "SamrDeleteAlias",
    ["12345778-1234-abcd-ef00-0123456789ab@91"] = "LsarQueryAuditSecurity",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@68"] = "LlsrProductSecuritySetA",
    ["c386ca3e-9061-4a72-821e-498d83be188f@39"] = "AudioSessionManagerGetAudioSession",
    ["12345778-1234-abcd-ef00-0123456789ac@22"] = "SamrAddMemberToGroup",
    ["12345778-1234-abcd-ef00-0123456789ac@4"] = "SamrShutdownSamServer",
    ["367abb81-9844-35f1-ad32-98f038001003@17"] = "QueryServiceConfigW",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@0"] = "RpcSrvEnableDhcp",
    ["338cd001-2244-31f1-aaaa-900038001003@22"] = "BaseRegSetValue",
    ["6bffd098-a112-3610-9833-46c3f87e345a@0"] = "NetrWkstaGetInfo",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@55"] = "NetrServerAliasEnum",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@4"] = "NspiSeekEntries",
    ["12345678-1234-abcd-ef00-0123456789ab@83"] = "RpcSeekPrinter",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@64"] = "PNP_GetServerSideDeviceInstallFlags",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@25"] = "RpcWinStationQueryLicense",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@6"] = "ElfrChangeNotify",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@27"] = "PNP_SetClassRegProp",
    ["367abb81-9844-35f1-ad32-98f038001003@1"] = "ControlService",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@12"] = "RpcSrvDeRegisterParams",
    ["6bffd098-a112-3610-9833-46c3f87e345a@21"] = "NetrGetJoinableOUs",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@36"] = "PNP_QueryRemove",
    ["12345778-1234-abcd-ef00-0123456789ab@23"] = "LsarGetSystemAccessAccount",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@24"] = "LlsrUserProductEnumW",
    ["6bffd098-a112-3610-9833-46c3f87e345a@20"] = "NetrGetJoinInformation",
    ["12345778-1234-abcd-ef00-0123456789ac@48"] = "SamrQueryDisplayInformation2",
    ["12345778-1234-abcd-ef00-0123456789ac@43"] = "SamrTestPrivateFunctionsUser",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@25"] = "NetrServerTransportAdd",
    ["12345778-1234-abcd-ef00-0123456789ab@70"] = "LsarRegisterAuditEvent",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@57"] = "RpcAsyncEnumPerMachineConnections",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@47"] = "LlsrServerProductEnumA",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@3"] = "SfcSrv_InitiateScan",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@55"] = "RpcAsyncAddPerMachineConnection",
    ["12345678-1234-abcd-ef00-0123456789ab@24"] = "RpcAddJob",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@20"] = "LlsrUserInfoSetW",
    ["99fcfec4-5260-101b-bbcb-00aa0021347a@5"] = "ServerAlive2",
    ["338cd001-2244-31f1-aaaa-900038001003@32"] = "OpenPerformanceText",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@45"] = "RpcAsyncEnumPrintProcessors",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@5"] = "DsRolerGetDcOperationProgress",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@4"] = "RpcLicensingSetPolicy",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@20"] = "PNP_DeleteClassKey",
    ["12345778-1234-abcd-ef00-0123456789ab@20"] = "LsarRemovePrivilegesFromAccount",
    ["12345778-1234-abcd-ef00-0123456789ab@34"] = "LsarDeleteObject",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@5"] = "R_WinsGetDbRecs",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@13"] = "nsi_entry_object_inq_next",
    ["2f5f3220-c126-1076-b549-074d078619da@7"] = "NDdeShareEnumA",
    ["338cd001-2244-31f1-aaaa-900038001003@19"] = "BaseRegRestoreKey",
    ["12345678-1234-abcd-ef00-01234567cffb@46"] = "NetrServerGetTrustInfo",
    ["12345678-1234-abcd-ef00-0123456789ab@41"] = "RpcPlayGdiScriptOnPrinterIC",
    ["12345678-1234-abcd-ef00-0123456789ab@78"] = "RpcGetPrinterDataEx",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@4"] = "KeyrCloseKeyService",
    ["338cd001-2244-31f1-aaaa-900038001003@15"] = "BaseRegOpenKey",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@11"] = "KeyrEnumerateCAs",
    ["367abb81-9844-35f1-ad32-98f038001003@47"] = "NotifyServiceStatusChange",
    ["12345678-1234-abcd-ef00-0123456789ab@61"] = "RpcAddPortEx",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@67"] = "RpcWinStationNotifyDisconnectPipe",
    ["12345778-1234-abcd-ef00-0123456789ac@57"] = "SamrConnect2",
    ["c386ca3e-9061-4a72-821e-498d83be188f@14"] = "AudioSessionGetLastInactivation",
    ["367abb81-9844-35f1-ad32-98f038001003@33"] = "GetServiceKeyNameA",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@20"] = "nsi_mgmt_inq_exp_age",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@62"] = "RpcAsyncInstallPrinterDriverFromPackage",
    ["12345778-1234-abcd-ef00-0123456789ab@78"] = "LsarOpenPolicySce",
    ["12345678-1234-abcd-ef00-0123456789ab@72"] = "RpcEnumPrinterData",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@73"] = "LlsrCertificateClaimAddCheckA",
    ["c386ca3e-9061-4a72-821e-498d83be188f@60"] = "AudioMeterGetAverageRMS",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@34"] = "NetprNameCanonicalize",
    ["12345678-1234-abcd-ef00-01234567cffb@28"] = "DsrGetSiteName",
    ["c386ca3e-9061-4a72-821e-498d83be188f@11"] = "AudioSessionGetProcessId",
    ["c386ca3e-9061-4a72-821e-498d83be188f@23"] = "AudioSessionSetMute",
    ["12345678-1234-abcd-ef00-0123456789ab@52"] = "RpcResetPrinter",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@56"] = "RpcAsyncDeletePerMachineConnection",
    ["2f5f3220-c126-1076-b549-074d078619da@13"] = "NDdeGetTrustedShareA",
    ["367abb81-9844-35f1-ad32-98f038001003@34"] = "ScGetCurrentGroupStateW",
    ["12345678-1234-abcd-ef00-01234567cffb@23"] = "NetrLogonGetTrustRid",
    ["12b81e99-f207-4a4c-85d3-77b42f76fd14@1"] = "SeclCreateProcessWithLogonExW",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@3"] = "RpcSrvReleaseLease",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@1"] = "NspiUnbind",
    ["894de0c0-0d55-11d3-a322-00c04fa321a1@2"] = "BaseInitiateShutdownEx",
    ["12345678-1234-abcd-ef00-0123456789ab@13"] = "RpcDeletePrinterDriver",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@15"] = "RpcWinStationShutdownSystem",
    ["12345778-1234-abcd-ef00-0123456789ab@9"] = "LsarClearAuditLog",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@7"] = "ElfrOpenELW",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@21"] = "ExecQueryAsync",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d6@2"] = "RpcSrvReleasePrefix",
    ["c386ca3e-9061-4a72-821e-498d83be188f@33"] = "AudioServerGetDevicePeriod",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@37"] = "PNP_RequestDeviceEject",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@5"] = "NetrCharDevQSetInfo",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@74"] = "LlsrCertificateClaimAddCheckW",
    ["12345678-1234-abcd-ef00-0123456789ab@101"] = "RpcGetCorePrinterDrivers",
    ["12345678-1234-abcd-ef00-0123456789ab@17"] = "RpcStartDocPrinter",
    ["338cd001-2244-31f1-aaaa-900038001003@0"] = "OpenClassesRoot",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@0"] = "FrsRpcSendCommPkt",
    ["6bffd098-a112-3610-9833-46c3f87e345a@18"] = "NetrValidateName",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@28"] = "PNP_CreateDevInst",
    ["99fcfec4-5260-101b-bbcb-00aa0021347a@3"] = "ServerAlive",
    ["12345778-1234-abcd-ef00-0123456789ac@49"] = "SamrGetDisplayEnumerationIndex2",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@9"] = "DRSGetMemberships",
    ["12345678-1234-abcd-ef00-0123456789ab@49"] = "RpcAddPrintProvidor",
    ["12345778-1234-abcd-ef00-0123456789ac@19"] = "SamrOpenGroup",
    ["6bffd098-a112-3610-9833-46c3f87e345a@10"] = "NetrUseDel",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@14"] = "winmmGetPnpInfo",
    ["12345678-1234-abcd-ef00-0123456789ab@38"] = "RpcConfigurePort",
    ["367abb81-9844-35f1-ad32-98f038001003@50"] = "ControlServiceExA",
    ["99fcfec4-5260-101b-bbcb-00aa0021347a@4"] = "ResolveOxid2",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@5"] = "RpcWinStationQueryInformation",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@9"] = "DsRolerUpgradeDownlevelServer",
    ["12345778-1234-abcd-ef00-0123456789ab@43"] = "LsarRetrievePrivateData",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@9"] = "RpcSrvRequestParams",
    ["12345778-1234-abcd-ef00-0123456789ac@67"] = "SamrValidatePassword",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@47"] = "NetrDfsSetServerInfo",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@39"] = "NetrpGetFileSecurity",
    ["c386ca3e-9061-4a72-821e-498d83be188f@44"] = "AudioSessionManagerAddAudioSessionClientNotification",
    ["c386ca3e-9061-4a72-821e-498d83be188f@2"] = "AudioServerInitialize",
    ["338cd001-2244-31f1-aaaa-900038001003@7"] = "BaseRegDeleteKey",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@1"] = "NetrDfsAdd",
    ["12345678-1234-abcd-ef00-0123456789ab@77"] = "RpcSetPrinterDataEx",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@7"] = "R_WinsBackup",
    ["338cd001-2244-31f1-aaaa-900038001003@14"] = "BaseRegNotifyChangeKeyValue",
    ["12345778-1234-abcd-ef00-0123456789ac@52"] = "SamrAddMultipleMembersToAlias",
    ["12345678-1234-abcd-ef00-0123456789ab@7"] = "RpcSetPrinter",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@1"] = "RpcLicensingCloseServer",
    ["12345778-1234-abcd-ef00-0123456789ab@35"] = "LsarEnumerateAccountsWithUserRight",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@10"] = "DeleteClass",
    ["12345678-1234-abcd-ef00-0123456789ab@90"] = "RpcSplOpenPrinter",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@21"] = "NetrDfsEnumEx",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@51"] = "PNP_GetResDesDataSize",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@2"] = "RpcAsyncSetJob",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@28"] = "RpcAsyncEnumPrinterDataEx",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@34"] = "PNP_AddID",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@5"] = "ept_inq_object",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@28"] = "NetrRemoteTOD",
    ["12345678-1234-abcd-ef00-0123456789ab@98"] = "RpcDeletePrinterConnection2",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@43"] = "RpcWinStationGetAllProcesses",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@3"] = "DnssrvEnumRecords",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@19"] = "CreateInstanceEnumAsync",
    ["12345678-1234-abcd-ef00-0123456789ab@34"] = "RpcEnumForms",
    ["338cd001-2244-31f1-aaaa-900038001003@35"] = "BaseRegDeleteKeyEx",
    ["6bffd098-a112-3610-9833-012892020162@0"] = "BrowserrServerEnum",
    ["378e52b0-c0a9-11cf-822d-00aa0051e40f@2"] = "SAGetNSAccountInformation",
    ["12345778-1234-abcd-ef00-0123456789ab@68"] = "LsarLookupNames3",
    ["12345778-1234-abcd-ef00-0123456789ac@46"] = "SamrQueryInformationDomain2",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@14"] = "RpcSrvQueryLeaseInfo",
    ["12345778-1234-abcd-ef00-0123456789ab@57"] = "LsarLookupSids2",
    ["12345678-1234-abcd-ef00-0123456789ab@93"] = "RpcCloseSpoolFileHandle",
    ["12345678-1234-abcd-ef00-0123456789ab@11"] = "RpcGetPrinterDriver",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@7"] = "gfxLogon",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@2"] = "NspiUpdateStat",
    ["12345778-1234-abcd-ef00-0123456789ac@34"] = "SamrOpenUser",
    ["367abb81-9844-35f1-ad32-98f038001003@26"] = "EnumServicesStatusA",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@13"] = "RpcAsyncEndPagePrinter",
    ["12345678-1234-abcd-ef00-01234567cffb@31"] = "NetrServerPasswordGet",
    ["6bffd098-a112-3610-9833-46c3f87e345a@2"] = "NetrWkstaUserEnum",
    ["12345778-1234-abcd-ef00-0123456789ab@31"] = "LsarLookupPrivilegeValue",
    ["86d35949-83c9-4044-b424-db363231fd0c@1"] = "SchRpcRegisterTask",
    ["894de0c0-0d55-11d3-a322-00c04fa321a1@1"] = "BaseAbortShutdown",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@51"] = "RpcAsyncAddMonitor",
    ["12345678-1234-abcd-ef00-0123456789ab@89"] = "RpcAddPrinterDriverEx",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@1"] = "nsi_group_mbr_add",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@10"] = "ElfrReadELW",
    ["00000143-0000-0000-c000-000000000046@0"] = "QueryInterface",
    ["12345778-1234-abcd-ef00-0123456789ac@32"] = "SamrRemoveMemberFromAlias",
    ["12345778-1234-abcd-ef00-0123456789ac@56"] = "SamrGetDomainPasswordInformation",
    ["12345778-1234-abcd-ef00-0123456789ab@55"] = "LsarOpenTrustedDomainByName",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@89"] = "LlsrCloseEx",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@21"] = "RpcAsyncAddForm",
    ["c386ca3e-9061-4a72-821e-498d83be188f@20"] = "AudioSessionGetVolume",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@53"] = "LlsrLocalProductInfoSetA",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@2"] = "SfcSrv_FileException",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@3"] = "FrsNOP",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@7"] = "NspiDNToEph",
    ["c386ca3e-9061-4a72-821e-498d83be188f@38"] = "AudioSessionManagerDestroy",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@8"] = "RpcLogonIdFromWinStationName",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@18"] = "RpcSrvGetClientId",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@14"] = "RpcAsyncEndDocPrinter",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@27"] = "RpcWinStationQueryUpdateRequired",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@73"] = "RpcAsyncEnumJobNamedProperties",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@7"] = "PNP_GetRootDeviceInstance",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@49"] = "RpcAsyncAddPort",
    ["12345678-1234-abcd-ef00-0123456789ab@55"] = "RpcFindNextPrinterChangeNotification",
    ["12345778-1234-abcd-ef00-0123456789ab@32"] = "LsarLookupPrivilegeName",
    ["86d35949-83c9-4044-b424-db363231fd0c@3"] = "SchRpcCreateFolder",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@11"] = "DRSGetNT4ChangeLog",
    ["12345678-1234-abcd-ef00-01234567cffb@9"] = "NetrAccountDeltas",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@1"] = "DsRolerDnsNameToFlatName",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@56"] = "LlsrServiceInfoSetW",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@14"] = "DRSRemoveDsServer",
    ["afa8bd80-7d8a-11c9-bef4-08002b102989@3"] = "stop_server_listening",
    ["12345678-1234-abcd-ef00-01234567cffb@14"] = "NetrLogonControl2",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@5"] = "nsi_group_mbr_inq_done",
    ["12345778-1234-abcd-ef00-0123456789ac@26"] = "SamrSetMemberAttributesOfGroup",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@0"] = "KeyrOpenKeyService",
    ["12345778-1234-abcd-ef00-0123456789ab@63"] = "CredrWriteDomainCredentials",
    ["12345778-1234-abcd-ef00-0123456789ac@31"] = "SamrAddMemberToAlias",
    ["68b58241-c259-4f03-a2e5-a2651dcbc930@2"] = "KSrGetCAs",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@50"] = "LlsrLocalProductInfoGetW",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@20"] = "DRSAddSidHistory",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@4"] = "R_WinsDoScavenging",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@18"] = "nsi_mgmt_entry_create",
    ["12345778-1234-abcd-ef00-0123456789ac@40"] = "SamrQueryDisplayInformation",
    ["367abb81-9844-35f1-ad32-98f038001003@21"] = "GetServiceKeyNameW",
    ["338cd001-2244-31f1-aaaa-900038001003@31"] = "BaseRegSaveKeyEx",
    ["12345678-1234-abcd-ef00-01234567cffb@33"] = "DsrAddressToSiteNamesW",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@65"] = "PNP_GetObjectPropKeys",
    ["6bffd098-a112-3610-9833-012892020162@9"] = "BrowserrSetNetlogonState",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@31"] = "RpcAsyncDeletePrinterDataEx",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@7"] = "nsi_profile_elt_add",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@4"] = "NetrDfsGetInfo",
    ["d3fbb514-0e3b-11cb-8fad-08002b1d29c3@3"] = "nsi_mgmt_handle_set_exp_age",
    ["12345678-1234-abcd-ef00-01234567cffb@6"] = "NetrServerPasswordSet",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@48"] = "NetrDfsCreateExitPoint",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@7"] = "RpcLicensingGetPolicyInformation",
    ["12345678-1234-abcd-ef00-0123456789ab@51"] = "RpcEnumPrintProcessorDatatypes",
    ["c386ca3e-9061-4a72-821e-498d83be188f@10"] = "AudioVolumeGetMasterVolumeLevelScalar",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@30"] = "RpcWinStationReadRegistry",
    ["12345678-1234-abcd-ef00-0123456789ab@14"] = "RpcAddPrintProcessor",
    ["c386ca3e-9061-4a72-821e-498d83be188f@17"] = "AudioSessionSetDisplayName",
    ["12345778-1234-abcd-ef00-0123456789ac@23"] = "SamrDeleteGroup",
    ["12345778-1234-abcd-ef00-0123456789ab@64"] = "CredrReadDomainCredentials",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@13"] = "NetrSessionDel",
    ["c386ca3e-9061-4a72-821e-498d83be188f@24"] = "AudioSessionGetChannelCount",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@66"] = "RpcAsyncGetPrinterDriverPackagePath",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@29"] = "NetrServerSetServiceBits",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@22"] = "PNP_GetInterfaceDeviceList",
    ["2f5f3220-c126-1076-b549-074d078619da@0"] = "NDdeShareAddW",
    ["c386ca3e-9061-4a72-821e-498d83be188f@37"] = "GetAudioSessionManager",
    ["6bffd098-a112-3610-9833-012892020162@4"] = "BrowserrDebugTrace",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@54"] = "RpcWinStationUpdateUserConfig",
    ["12345678-1234-abcd-ef00-0123456789ab@10"] = "RpcEnumPrinterDrivers",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@23"] = "RpcSrvRegisterConnectionStateNotification",
    ["12345778-1234-abcd-ef00-0123456789ab@89"] = "LsarLookupAuditSubCategoryName",
    ["12345778-1234-abcd-ef00-0123456789ac@47"] = "SamrQueryInformationUser2",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@13"] = "ElfrBackupELFA",
    ["12345678-1234-abcd-ef00-0123456789ab@37"] = "RpcAddPort",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@65"] = "RpcWinStationCheckLoopBack",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@5"] = "DnssrvOperation2",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@10"] = "winmmUnregisterSessionNotification",
    ["367abb81-9844-35f1-ad32-98f038001003@35"] = "EnumServiceGroupW",
    ["12345778-1234-abcd-ef00-0123456789ab@72"] = "LsarUnregisterAuditEvent",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@38"] = "RpcAsyncEnumPrinters",
    ["12345778-1234-abcd-ef00-0123456789ac@64"] = "SamrConnect5",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@3"] = "NspiQueryRows",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@6"] = "DRSReplicaDel",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@48"] = "RpcAsyncEnumMonitors",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@50"] = "RpcAsyncSetPort",
    ["338cd001-2244-31f1-aaaa-900038001003@12"] = "BaseRegGetKeySecurity",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@9"] = "R_WinsPullRange",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@7"] = "FrsBackupComplete",
    ["c386ca3e-9061-4a72-821e-498d83be188f@13"] = "AudioSessionGetLastActivation",
    ["367abb81-9844-35f1-ad32-98f038001003@29"] = "QueryServiceConfigA",
    ["86d35949-83c9-4044-b424-db363231fd0c@14"] = "SchRpcRename",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@58"] = "LlsrReplConnect",
    ["12345778-1234-abcd-ef00-0123456789ab@3"] = "LsarQuerySecurityObject",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@12"] = "RpcAsyncWritePrinter",
    ["c386ca3e-9061-4a72-821e-498d83be188f@47"] = "AudioVolumeGetChannelCount",
    ["12345778-1234-abcd-ef00-0123456789ab@38"] = "LsarRemoveAccountRights",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@30"] = "RpcAsyncDeletePrinterData",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@10"] = "R_WinsSetPriorityClass",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@41"] = "LlsrMappingAddA",
    ["12345778-1234-abcd-ef00-0123456789ac@15"] = "SamrEnumerateAliasesInDomain",
    ["c386ca3e-9061-4a72-821e-498d83be188f@46"] = "AudioVolumeDisconnect",
    ["338cd001-2244-31f1-aaaa-900038001003@20"] = "BaseRegSaveKey",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@23"] = "RpcWinStationActivateLicense",
    ["2f5f3220-c126-1076-b549-074d078619da@8"] = "NDdeShareEnumW",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@3"] = "ept_map",
    ["12345678-1234-abcd-ef00-0123456789ab@18"] = "RpcStartPagePrinter",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@4"] = "RpcAsyncEnumJobs",
    ["12345778-1234-abcd-ef00-0123456789ab@47"] = "LsarSetInformationPolicy2",
    ["12345678-1234-abcd-ef00-01234567cffb@0"] = "NetrLogonUasLogon",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@13"] = "DRSWriteSPN",
    ["12345778-1234-abcd-ef00-0123456789ab@48"] = "LsarQueryTrustedDomainInfoByName",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d6@1"] = "RpcSrvRenewPrefix",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@7"] = "NetrCharDevQPurgeSelf",
    ["0a74ef1c-41a4-4e06-83ae-dc74fb1cdd53@0"] = "ItSrvRegisterIdleTask",
    ["6bffd098-a112-3610-9833-46c3f87e345a@12"] = "NetrMessageBufferSend",
    ["12345678-1234-abcd-ef00-0123456789ab@88"] = "RpcXcvData",
    ["12345678-1234-abcd-ef00-01234567cffb@17"] = "NetrDatabaseRedo",
    ["12345778-1234-abcd-ef00-0123456789ab@82"] = "CredrFindBestCredential",
    ["338cd001-2244-31f1-aaaa-900038001003@2"] = "OpenLocalMachine",
    ["12345778-1234-abcd-ef00-0123456789ab@27"] = "LsarSetInformationTrustedDomain",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@11"] = "NetrFileClose",
    ["86d35949-83c9-4044-b424-db363231fd0c@16"] = "SchRpcGetLastRunInfo",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@7"] = "RpcSrvStaticRefreshParams",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@72"] = "RpcWinStationUnRegisterNotificationEvent",
    ["12345678-1234-abcd-ef00-0123456789ab@26"] = "RpcGetPrinterData",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@10"] = "NetrFileGetInfo",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@70"] = "RpcAsyncGetJobNamedPropertyValue",
    ["c386ca3e-9061-4a72-821e-498d83be188f@19"] = "AudioSessionSetSessionClass",
    ["6bffd098-a112-3610-9833-46c3f87e345a@25"] = "NetrValidateName2",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@3"] = "RpcWinStationEnumerate",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@9"] = "nsi_profile_elt_inq_begin",
    ["12345678-1234-abcd-ef00-0123456789ab@31"] = "RpcDeleteForm",
    ["12345678-1234-abcd-ef00-01234567cffb@16"] = "NetrDatabaseSync2",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@19"] = "R_WinsDoScavengingNew",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@44"] = "NetrDfsCreateLocalPartition",
    ["c386ca3e-9061-4a72-821e-498d83be188f@35"] = "PolicyConfigGetShareMode",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@70"] = "RpcWinStationGetAllProcesses_NT6",
    ["12345778-1234-abcd-ef00-0123456789ac@66"] = "SamrSetDSRMPassword",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@30"] = "LlsrMappingInfoGetW",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@2"] = "NetrCharDevControl",
    ["12345778-1234-abcd-ef00-0123456789ab@2"] = "LsarEnumeratePrivileges",
    ["1ff70682-0a51-30e8-076d-740be8cee98b@0"] = "NetrJobAdd",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@3"] = "NetrCharDevQEnum",
    ["12345678-1234-abcd-ef00-0123456789ab@58"] = "RpcReplyOpenPrinter",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@3"] = "gfxRemoveGfx",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@23"] = "RpcAsyncGetForm",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@24"] = "DRSQuerySitesByCost",
    ["12345778-1234-abcd-ef00-0123456789ac@38"] = "SamrChangePasswordUser",
    ["338cd001-2244-31f1-aaaa-900038001003@17"] = "BaseRegQueryValue",
    ["367abb81-9844-35f1-ad32-98f038001003@8"] = "UnlockServiceDatabase",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@54"] = "LlsrServiceInfoGetW",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@2"] = "NetrDfsRemove",
    ["d95afe70-a6d5-4259-822e-2c84da1ddb0d@0"] = "WsdrInitiateShutdown",
    ["c386ca3e-9061-4a72-821e-498d83be188f@54"] = "AudioVolumeGetChannelVolumeLevel",
    ["f309ad18-d86a-11d0-a075-00c04fb68820@5"] = "WBEMLogin",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@12"] = "EcUnknown0xC",
    ["12345778-1234-abcd-ef00-0123456789ac@12"] = "SamrCreateUserInDomain",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@6"] = "RpcWinStationSetInformation",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@13"] = "RpcSrvEnumInterfaces",
    ["338cd001-2244-31f1-aaaa-900038001003@5"] = "BaseRegCloseKey",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@0"] = "ept_insert",
    ["12345778-1234-abcd-ef00-0123456789ab@80"] = "LsarAdtUnregisterSecurityEventSource",
    ["12345678-1234-abcd-ef00-0123456789ab@53"] = "RpcGetPrinterDriver2",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@73"] = "PNP_SetActiveService",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@8"] = "NetrConnectionEnum",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@18"] = "NetrShareDel",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@42"] = "RpcWinStationCheckForApplicationName",
    ["12345778-1234-abcd-ef00-0123456789ab@28"] = "LsarOpenSecret",
    ["12345678-1234-abcd-ef00-01234567cffb@12"] = "NetrLogonControl",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@0"] = "NetrCharDevEnum",
    ["c386ca3e-9061-4a72-821e-498d83be188f@56"] = "AudioVolumeSetMute",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@9"] = "NetrFileEnum",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@8"] = "ElfrRegisterEventSourceW",
    ["12345778-1234-abcd-ef00-0123456789ab@17"] = "LsarOpenAccount",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@20"] = "NetrDfsRemove2",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@6"] = "DsRolerGetDcOperationResults",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@15"] = "ElfrRegisterEventSourceA",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@32"] = "LlsrMappingInfoSetW",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@47"] = "RpcWinStationBroadcastSystemMessage",
    ["12345778-1234-abcd-ef00-0123456789ac@16"] = "SamrGetAliasMembership",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@2"] = "DnssrvComplexOperation",
    ["6bffd098-a112-3610-9833-46c3f87e345a@8"] = "NetrUseAdd",
    ["12345678-1234-abcd-ef00-01234567cffb@4"] = "NetrServerReqChallenge",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@61"] = "LlsrReplicationServerAddW",
    ["2f5f3220-c126-1076-b549-074d078619da@2"] = "NDdeShareDelW",
    ["338cd001-2244-31f1-aaaa-900038001003@25"] = "BaseAbortSystemShutdown",
    ["c386ca3e-9061-4a72-821e-498d83be188f@0"] = "AudioServerConnect",
    ["0a74ef1c-41a4-4e06-83ae-dc74fb1cdd53@3"] = "ItSrvSetDetectionParameters",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426@0"] = "NspiBind",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@43"] = "NetrDfsGetVersion",
    ["367abb81-9844-35f1-ad32-98f038001003@19"] = "StartServiceW",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@6"] = "gfxOpenGfx",
    ["6bffd098-a112-3610-9833-46c3f87e345a@17"] = "NetrUnjoinDomain",
    ["12345778-1234-abcd-ef00-0123456789ab@56"] = "LsarTestCall",
    ["12345778-1234-abcd-ef00-0123456789ac@10"] = "SamrCreateGroupInDomain",
    ["367abb81-9844-35f1-ad32-98f038001003@53"] = "ScValidatePnPService",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@37"] = "RpcWinStationTerminateProcess",
    ["c386ca3e-9061-4a72-821e-498d83be188f@48"] = "AudioVolumeSetMasterVolumeLevel",
    ["12345678-1234-abcd-ef00-0123456789ab@102"] = "RpcCorePrinterDriverInstalled",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@10"] = "EcDoConnectEx",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@20"] = "RpcSrvGetOriginalSubnetMask",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@36"] = "LlsrMappingUserAddW",
    ["c386ca3e-9061-4a72-821e-498d83be188f@65"] = "AudioVolumeStepUp",
    ["12345678-1234-abcd-ef00-0123456789ab@48"] = "RpcDeletePrintProcessor",
    ["367abb81-9844-35f1-ad32-98f038001003@37"] = "ChangeServiceConfig2W",
    ["367abb81-9844-35f1-ad32-98f038001003@30"] = "QueryServiceLockStatusA",
    ["12345778-1234-abcd-ef00-0123456789ac@51"] = "SamrQueryDisplayInformation3",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@6"] = "KeyrSetDefaultProvider",
    ["86d35949-83c9-4044-b424-db363231fd0c@13"] = "SchRpcDelete",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@13"] = "PNP_GetDeviceRegProp",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@38"] = "PNP_IsDockStationPresent",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@11"] = "RpcWinStationVirtualOpen",
    ["12345778-1234-abcd-ef00-0123456789ac@28"] = "SamrQueryInformationAlias",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@17"] = "NetrDfsSetDcAddress",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@11"] = "nsi_profile_elt_inq_done",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@0"] = "PNP_Disconnect",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@9"] = "RpcAsyncGetPrinter",
    ["12345678-1234-abcd-ef00-0123456789ab@80"] = "RpcEnumPrinterKey",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@5"] = "NetrDfsEnum",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@5"] = "gfxModifyGx",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@50"] = "NetrDfsModifyPrefix",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@13"] = "NetrDfsRemoveStdRoot",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@15"] = "RpcAsyncAbortPrinter",
    ["86d35949-83c9-4044-b424-db363231fd0c@11"] = "SchRpcStop",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@48"] = "RpcWinStationSendWindowMessage",
    ["000001a0-0000-0000-c000-000000000046@0"] = "QueryInterfaceIRemoteSCMActivator",
    ["c386ca3e-9061-4a72-821e-498d83be188f@61"] = "AudioMeterGetChannelsRMS",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@4"] = "nsi_group_mbr_inq_next",
    ["99fcfec4-5260-101b-bbcb-00aa0021347a@1"] = "SimplePing",
    ["d3fbb514-0e3b-11cb-8fad-08002b1d29c3@2"] = "nsi_binding_lookup_next",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@52"] = "RpcAsyncDeleteMonitor",
    ["12345778-1234-abcd-ef00-0123456789ac@25"] = "SamrGetMembersInGroup",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@69"] = "RpcRemoteAssistancePrepareSystemRestore",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@54"] = "PNP_QueryResConfList",
    ["f50aac00-c7f3-428e-a022-a6b71bfb9d43@2"] = "SSCatDBEnumCatalogs",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@2"] = "KeyrEnumerateProviderTypes",
    ["12345778-1234-abcd-ef00-0123456789ac@14"] = "SamrCreateAliasInDomain",
    ["12345678-1234-abcd-ef00-01234567cffb@19"] = "NetrEnumerateTrustedDomains",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@12"] = "wdmDriverOpenDrvRegKey",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@72"] = "LlsrCertificateClaimEnumW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@75"] = "LlsrCertificateClaimAddA",
    ["338cd001-2244-31f1-aaaa-900038001003@24"] = "BaseInitiateSystemShutdown",
    ["338cd001-2244-31f1-aaaa-900038001003@21"] = "BaseRegSetKeySecurity",
    ["12345678-1234-abcd-ef00-0123456789ab@28"] = "RpcWaitForPrinterChange",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@68"] = "RpcAsyncReadPrinter",
    ["12345678-1234-abcd-ef00-0123456789ab@54"] = "RpcClientFindFirstPrinterChangeNotification",
    ["12345678-1234-abcd-ef00-0123456789ab@104"] = "RpcReportJobProcessingProgress",
    ["0d72a7d4-6148-11d1-b4aa-00c04fb66ea0@0"] = "SSCertProtectFunction",
    ["12345778-1234-abcd-ef00-0123456789ab@84"] = "LsarQueryAuditPolicy",
    ["12345778-1234-abcd-ef00-0123456789ac@2"] = "SamrSetSecurityObject",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@1"] = "RpcSrvRenewLease",
    ["c386ca3e-9061-4a72-821e-498d83be188f@7"] = "AudioServerGetMixFormat",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@16"] = "DeleteInstance",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@6"] = "ept_mgmt_delete",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@0"] = "EcDoConnect",
    ["c386ca3e-9061-4a72-821e-498d83be188f@63"] = "AudioMeterGetChannelsPeakValues",
    ["12345678-1234-abcd-ef00-0123456789ab@45"] = "RpcPrinterMessageBox",
    ["6bffd098-a112-3610-9833-46c3f87e345a@6"] = "NetrWkstaTransportAdd",
    ["00000143-0000-0000-c000-000000000046@4"] = "RemAddRef",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@0"] = "DRSBind",
    ["5a7b91f8-ff00-11d0-a9b2-00c04fb6e6fc@0"] = "NetrSendMessage",
    ["12345678-1234-abcd-ef00-0123456789ab@4"] = "RpcEnumJobs",
    ["86d35949-83c9-4044-b424-db363231fd0c@10"] = "SchRpcStopInstance",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@20"] = "NetrShareCheck",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@48"] = "PNP_FreeResDes",
    ["12345678-1234-abcd-ef00-0123456789ab@103"] = "RpcGetPrinterDriverPackagePath",
    ["367abb81-9844-35f1-ad32-98f038001003@31"] = "StartServiceA",
    ["367abb81-9844-35f1-ad32-98f038001003@36"] = "ChangeServiceConfig2A",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@8"] = "EcRNetGetDCName",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@1"] = "RpcWinStationCloseServer",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@47"] = "RpcAsyncEnumPorts",
    ["6bffd098-a112-3610-9833-012892020162@2"] = "BrowserrQueryOtherDomains",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@59"] = "RpcSyncUnRegisterForRemoteNotifications",
    ["367abb81-9844-35f1-ad32-98f038001003@49"] = "CloseNotifyHandle",
    ["12345678-1234-abcd-ef00-0123456789ab@29"] = "RpcClosePrinter",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@19"] = "RpcWinStationShadowTarget",
    ["12345678-1234-abcd-ef00-0123456789ab@62"] = "RpcRemoteFindFirstPrinterChangeNotification",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@25"] = "RpcSrvGetNotificationStatus",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@78"] = "LlsrReplicationProductSecurityAddW",
    ["12345678-1234-abcd-ef00-0123456789ab@66"] = "RpcRouterReplyPrinterEx",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@61"] = "PNP_GetCustomDevProp",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@16"] = "nsi_mgmt_binding_unexport",
    ["6bffd098-a112-3610-9833-46c3f87e345a@30"] = "NetrEnumerateComputerNames",
    ["12345778-1234-abcd-ef00-0123456789ac@62"] = "SamrConnect4",
    ["12345678-1234-abcd-ef00-0123456789ab@5"] = "RpcAddPrinter",
    ["86d35949-83c9-4044-b424-db363231fd0c@2"] = "SchRpcRetrieveTask",
    ["367abb81-9844-35f1-ad32-98f038001003@27"] = "OpenSCManagerA",
    ["12345778-1234-abcd-ef00-0123456789ab@13"] = "LsarEnumerateTrustedDomains",
    ["2f5f3220-c126-1076-b549-074d078619da@14"] = "NDdeGetTrustedShareW",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@21"] = "NetrServerGetInfo",
    ["12345678-1234-abcd-ef00-01234567cffb@11"] = "NetrGetDCName",
    ["12345678-1234-abcd-ef00-0123456789ab@57"] = "RpcRouterFindFirstPrinterChangeNotificationOld",
    ["2f5f3220-c126-1076-b549-074d078619da@10"] = "NDdeShareSetInfoW",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@2"] = "R_WinsTrigger",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@12"] = "RpcWinStationBeepOpen",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@5"] = "ElfrOldestRecord",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@22"] = "RpcAsyncDeleteForm",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@20"] = "ElfrDeregisterClusterSvc",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@11"] = "NetrDfsRemoveFtRoot",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@17"] = "DRSAddEntry",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426@8"] = "FrsBackupComplete",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@60"] = "LlsrReplicationRequestW",
    ["17fdd703-1827-4e34-79d4-24a55c53bb37@0"] = "NetrMessageNameAdd",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@3"] = "DsRolerDcAsReplica",
    ["c386ca3e-9061-4a72-821e-498d83be188f@40"] = "AudioSessionManagerGetCurrentSession",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@46"] = "LlsrServerProductEnumW",
    ["12345678-1234-abcd-ef00-0123456789ab@63"] = "RpcSpoolerInit",
    ["367abb81-9844-35f1-ad32-98f038001003@6"] = "QueryServiceStatus",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@21"] = "DRSGetMemberships2",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@4"] = "gfxAddGfx",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@2"] = "gfxCreateGfxList",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d6@0"] = "RpcSrvRequestPrefix",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@6"] = "PNP_ValidateDeviceInstance",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@7"] = "RpcAsyncDeletePrinter",
    ["12345778-1234-abcd-ef00-0123456789ab@16"] = "LsarCreateSecret",
    ["367abb81-9844-35f1-ad32-98f038001003@5"] = "SetServiceObjectSecurity",
    ["12345778-1234-abcd-ef00-0123456789ab@6"] = "LsarOpenPolicy",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@0"] = "RpcLicensingOpenServer",
    ["12345778-1234-abcd-ef00-0123456789ab@86"] = "LsarEnumerateAuditCategories",
    ["c386ca3e-9061-4a72-821e-498d83be188f@9"] = "AudioServerGetDevicePeriod",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@62"] = "LlsrReplicationServerServiceAddW",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@15"] = "NetrDfsAddStdRootForced",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@64"] = "RpcWinStationFUSCanRemoteUserDisconnect",
    ["12345678-1234-abcd-ef00-0123456789ab@76"] = "RpcClusterSplIsAlive",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@7"] = "LlsrProductEnumA",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@9"] = "EcDoRpcExt",
    ["367abb81-9844-35f1-ad32-98f038001003@12"] = "CreateServiceW",
    ["12345778-1234-abcd-ef00-0123456789ab@29"] = "LsarSetSecret",
    ["6bffd098-a112-3610-9833-46c3f87e345a@3"] = "NetrWkstaUserGetInfo",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@1"] = "PNP_Connect",
    ["12345678-1234-abcd-ef00-01234567cffb@43"] = "DsrGetForestTrustInformation",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@36"] = "RpcWinStationEnumerateProcesses",
    ["12345778-1234-abcd-ef00-0123456789ac@42"] = "SamrTestPrivateFunctionsDomain",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@19"] = "DRSGetReplInfo",
    ["12345778-1234-abcd-ef00-0123456789ac@44"] = "SamrGetUserDomainPasswordInformation",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@8"] = "DRSVerifyNames",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@59"] = "LlsrReplClose",
    ["12345778-1234-abcd-ef00-0123456789ab@75"] = "CredrRename",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@67"] = "PNP_SetObjectProp",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@42"] = "NetrServerSetServiceBitsEx",
    ["c386ca3e-9061-4a72-821e-498d83be188f@1"] = "AudioServerDisconnect",
    ["12345778-1234-abcd-ef00-0123456789ab@65"] = "CredrDelete",
    ["86d35949-83c9-4044-b424-db363231fd0c@0"] = "SchRpcHighestVersion",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@42"] = "RpcAsyncDeletePrinterDriver",
    ["12345778-1234-abcd-ef00-0123456789ab@36"] = "LsarEnumerateAccountRights",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@23"] = "ElfrFlushEL",
    ["12345678-1234-abcd-ef00-01234567cffb@32"] = "NetrLogonSendToSam",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@22"] = "NetrServerSetInfo",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@2"] = "RpcLicensingLoadPolicy",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@22"] = "ExecNotificationQuery",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@43"] = "LlsrMappingDeleteA",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@21"] = "nsi_mgmt_inq_set_age",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@56"] = "RpcWinStationRegisterConsoleNotification",
    ["12345778-1234-abcd-ef00-0123456789ac@58"] = "SamrSetInformationUser2",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@8"] = "RpcSrvRemoveDnsRegistrations",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@59"] = "RpcWinStationShadowStop",
    ["12345778-1234-abcd-ef00-0123456789ac@60"] = "SamrGetBootKeyInformation",
    ["2f5f3220-c126-1076-b549-074d078619da@3"] = "NDdeGetShareSecurityA",
    ["12345778-1234-abcd-ef00-0123456789ac@13"] = "SamrEnumerateUsersInDomain",
    ["f309ad18-d86a-11d0-a075-00c04fb68820@3"] = "EstablishPosition",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@5"] = "EcRUnregisterPushNotification",
    ["12345678-1234-abcd-ef00-0123456789ab@85"] = "RpcAddPerMachineConnection",
    ["378e52b0-c0a9-11cf-822d-00aa0051e40f@3"] = "SAGetAccountInformation",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@7"] = "NetrDfsMove",
    ["367abb81-9844-35f1-ad32-98f038001003@51"] = "ControlServiceExW",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@33"] = "NetprNameValidate",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@3"] = "ElfrDeregisterEventSource",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@49"] = "RpcWinStationNotifyNewSession",
    ["6bffd098-a112-3610-9833-46c3f87e345a@27"] = "NetrAddAlternateComputerName",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@36"] = "NetrShareEnumSticky",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@57"] = "LlsrServiceInfoSetA",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@19"] = "nsi_mgmt_entry_inq_if_ids",
    ["12345678-1234-abcd-ef00-01234567cffb@49"] = "NetrChainSetClientAttributes",
    ["12345678-1234-abcd-ef00-0123456789ab@69"] = "RpcSplOpenPrinter",
    ["12345678-1234-abcd-ef00-01234567cffb@5"] = "NetrServerAuthenticate",
    ["12345678-1234-abcd-ef00-0123456789ab@21"] = "RpcAbortPrinter",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@8"] = "NetrDfsManagerGetConfigInfo",
    ["82273fdc-e32a-18c3-3f78-827929dc23ea@22"] = "ElfrGetLogInformation",
    ["12345778-1234-abcd-ef00-0123456789ab@52"] = "LsarCloseTrustedDomainEx",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@85"] = "LlsrLocalServiceInfoSetW",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@27"] = "LlsrUserProductDeleteA",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@17"] = "R_WinsGetDbRecsByName",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@66"] = "LlsrProductSecurityGetA",
    ["367abb81-9844-35f1-ad32-98f038001003@10"] = "ScSetServiceBitsW",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@13"] = "CreateClassEnumAsync",
    ["338cd001-2244-31f1-aaaa-900038001003@10"] = "BaseRegEnumValue",
    ["12345778-1234-abcd-ef00-0123456789ab@4"] = "LsarSetSecurityObject",
    ["00000143-0000-0000-c000-000000000046@2"] = "Release",
    ["12345678-1234-abcd-ef00-0123456789ab@19"] = "RpcWritePrinter",
    ["12345678-1234-abcd-ef00-01234567cffb@22"] = "NetrLogonSetServiceBits",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076@4"] = "DnssrvUpdateRecord",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@14"] = "RpcWinStationReset",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@22"] = "DRSReplicaVerifyObjects",
    ["12345678-1234-abcd-ef00-01234567cffb@25"] = "NetrLogonComputeClientDigest",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@25"] = "RpcAsyncEnumForms",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@24"] = "PNP_RegisterDeviceClassAssociation",
    ["a4f1db00-ca47-1067-b31f-00dd010662da@11"] = "EcDoRpcExt2",
    ["367abb81-9844-35f1-ad32-98f038001003@15"] = "OpenSCManagerW",
    ["00000143-0000-0000-c000-000000000046@6"] = "RemQueryInterface2",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@12"] = "nsi_entry_object_inq_begin",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8@3"] = "RpcLicensingUnloadPolicy",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@4"] = "RpcSrvSetFallbackParams",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@3"] = "DRSGetNCChanges",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@5"] = "RpcSrvGetFallbackParams",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@40"] = "RpcAsyncEnumPrinterDrivers",
    ["6bffd098-a112-3610-9833-46c3f87e345a@13"] = "NetrWorkstationStatisticsGet",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@82"] = "LlsrLocalServiceEnumA",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@34"] = "LlsrMappingUserEnumW",
    ["12345778-1234-abcd-ef00-0123456789ab@60"] = "CredrWrite",
    ["86d35949-83c9-4044-b424-db363231fd0c@8"] = "SchRpcEnumInstances",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@17"] = "RpcAsyncGetPrinterDataEx",
    ["367abb81-9844-35f1-ad32-98f038001003@39"] = "QueryServiceConfig2W",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@35"] = "LlsrMappingUserEnumA",
    ["6bffd098-a112-3610-9833-46c3f87e345a@7"] = "NetrWkstaTransportDel",
    ["12345778-1234-abcd-ef00-0123456789ac@50"] = "SamrCreateUser2InDomain",
    ["12345778-1234-abcd-ef00-0123456789ab@21"] = "LsarGetQuotasForAccount",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@26"] = "NetrServerTransportEnum",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@31"] = "RpcWinStationWaitForConnect",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@50"] = "RpcServerGetInternetConnectorStatus",
    ["6bffd098-a112-3610-9833-46c3f87e345a@16"] = "NetrJoinDomain",
    ["12345678-1234-abcd-ef00-0123456789ab@73"] = "RpcDeletePrinterData",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@7"] = "KeyrEnroll",
    ["338cd001-2244-31f1-aaaa-900038001003@1"] = "OpenCurrentUser",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@6"] = "RpcAsyncScheduleJob",
    ["c386ca3e-9061-4a72-821e-498d83be188f@28"] = "AudioSessionGetAllVolumes",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed@45"] = "RpcWinStationGetTermSrvCountersValue",
    ["12345678-1234-abcd-ef00-0123456789ab@74"] = "RpcClusterSplOpen",
    ["86d35949-83c9-4044-b424-db363231fd0c@15"] = "SchRpcScheduledRuntimes",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@60"] = "RpcSyncRefreshRemoteNotifications",
    ["2f5f3220-c126-1076-b549-074d078619da@11"] = "NDdeSetTrustedShareA",
    ["12345778-1234-abcd-ef00-0123456789ab@42"] = "LsarStorePrivateData",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@23"] = "DRSGetObjectExistence",
    ["f50aac00-c7f3-428e-a022-a6b71bfb9d43@1"] = "SSCatDBDeleteCatalog",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@15"] = "R_WinsDeleteWins",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4@8"] = "nsi_profile_elt_remove",
    ["2f5f3220-c126-1076-b549-074d078619da@1"] = "NDdeShareDelA",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@13"] = "winmmAdvisePreferredDeviceChange",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850@4"] = "SfcSrv_PurgeCache",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@1"] = "ept_delete",
    ["12345778-1234-abcd-ef00-0123456789ac@35"] = "SamrDeleteUser",
    ["12345778-1234-abcd-ef00-0123456789ab@46"] = "LsarQueryInformationPolicy2",
    ["c386ca3e-9061-4a72-821e-498d83be188f@62"] = "AudioMeterGetPeakValue",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5@26"] = "RpcSrvGetDhcpServicedConnections",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5@7"] = "DsRolerCancel",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@1"] = "gfxCreateGfxFactoriesList",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b@66"] = "PNP_GetObjectProp",
    ["12345778-1234-abcd-ef00-0123456789ac@53"] = "SamrRemoveMultipleMembersFromAlias",
    ["12345678-1234-abcd-ef00-0123456789ab@64"] = "RpcResetPrinterEx",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@16"] = "LlsrUserEnumW",
    ["12345778-1234-abcd-ef00-0123456789ab@69"] = "CredrGetSessionTypes",
    ["0a74ef1c-41a4-4e06-83ae-dc74fb1cdd53@2"] = "ItSrvProcessIdleTasks",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa@4"] = "ept_lookup_handle_free",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188@14"] = "NetrShareAdd",
    ["c386ca3e-9061-4a72-821e-498d83be188f@41"] = "AudioSessionManagerGetExistingSession",
    ["12345678-1234-abcd-ef00-0123456789ab@86"] = "RpcDeletePerMachineConnection",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b@5"] = "KeyrGetDefaultProvider",
    ["76f03f96-cdfd-44fc-a22c-64950a001209@10"] = "RpcAsyncStartDocPrinter",
    ["338cd001-2244-31f1-aaaa-900038001003@4"] = "OpenUsers",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5@0"] = "gfxCreateZoneFactoriesList",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@8"] = "PutClass",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@40"] = "LlsrMappingAddW",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@10"] = "NetrDfsAddFtRoot",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2@2"] = "DRSReplicaSync",
    ["9556dc99-828c-11cf-a37e-00aa003240c7@23"] = "ExecNotificationQueryAsync",
    ["12345678-1234-abcd-ef00-0123456789ab@35"] = "RpcEnumPorts",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@18"] = "R_WinsStatusWHdl",
    ["367abb81-9844-35f1-ad32-98f038001003@13"] = "EnumDependentServicesW",
    ["12345778-1234-abcd-ef00-0123456789ab@74"] = "LsarSetForestTrustInformation",
    ["2f5f3220-c126-1076-b549-074d078619da@9"] = "NDdeShareGetInfoW",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673@0"] = "NetrDfsManagerGetVersion",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe@6"] = "R_WinsTerm",
    ["12345678-1234-abcd-ef00-01234567cffb@2"] = "NetrLogonSamLogon",
    ["c386ca3e-9061-4a72-821e-498d83be188f@6"] = "AudioServerGetStreamLatency",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d@11"] = "LlsrProductUserEnumA",
    ["00020400-0000-0000-c000-000000000046@3"] = "GetTypeInfoCount",
    ["00020400-0000-0000-c000-000000000046@4"] = "GetTypeInfo",
    ["00020400-0000-0000-c000-000000000046@5"] = "GetIDsOfNames",
    ["00020400-0000-0000-c000-000000000046@6"] = "Invoke"
}

endpoint_map = {
    ["82273fdc-e32a-18c3-3f78-827929dc23ea"] = "eventlog",
    ["51c82175-844e-4750-b0d8-ec255555bc06"] = "KMS",
    ["17fdd703-1827-4e34-79d4-24a55c53bb37"] = "msgsvc",
    ["dc12a681-737f-11cf-884d-00aa004b2e24"] = "IWbemClassObject interface",
    ["338cd001-2244-31f1-aaaa-900038001003"] = "winreg",
    ["68b58241-c259-4f03-a2e5-a2651dcbc930"] = "IKeySvc2",
    ["c49e32c6-bc8b-11d2-85d4-00105a1f8304"] = "IWbemBackupRestoreEx interface",
    ["2f59a331-bf7d-48cb-9ec5-7c090d76e8b8"] = "lcrpc",
    ["44aca674-e8fc-11d0-a07c-00c04fb68820"] = "IWbemContext interface",
    ["0b6edbfa-4a24-4fc6-8a23-942b1eca65d1"] = "IRPCAsyncNotify",
    ["7c857801-7381-11cf-884d-00aa004b2e24"] = "IWbemObjectSink interface",
    ["45f52c28-7f9f-101a-b52b-08002b2efabe"] = "winspipe",
    ["8d9f4e40-a03d-11ce-8f69-08003e30051b"] = "pnp",
    ["423ec01e-2e35-11d2-b604-00104b703efd"] = "IWbemWCOSmartEnum interface",
    ["e3514235-4b06-11d1-ab04-00c04fc2dcd2"] = "drsuapi",
    ["6bffd098-a112-3610-9833-46c3f87e345a"] = "wkssvc",
    ["1ff70682-0a51-30e8-076d-740be8cee98b"] = "atsvc",
    ["d95afe70-a6d5-4259-822e-2c84da1ddb0d"] = "WindowsShutdown",
    ["12b81e99-f207-4a4c-85d3-77b42f76fd14"] = "ISeclogon",
    ["342cfd40-3c6c-11ce-a893-08002b2e9c6d"] = "llsrpc",
    ["99fcfec4-5260-101b-bbcb-00aa0021347a"] = "IObjectExporter",
    ["44aca675-e8fc-11d0-a07c-00c04fb68820"] = "IWbemCallResult interface",
    ["12345778-1234-abcd-ef00-0123456789ab"] = "lsarpc",
    ["5ca4a760-ebb1-11cf-8611-00a0245420ed"] = "winstation_rpc",
    ["76f03f96-cdfd-44fc-a22c-64950a001209"] = "IRemoteWinspool",
    ["3d267954-eeb7-11d1-b94e-00c04fa3080d"] = "HydraLsPipe",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c4"] = "NsiM",
    ["6bffd098-a112-3610-9833-012892020162"] = "browser",
    ["f50aac00-c7f3-428e-a022-a6b71bfb9d43"] = "ICatDBSvc",
    ["541679AB-2E5F-11d3-B34E-00104BCC4B4A"] = "IWbemLoginHelper interface",
    ["f5cc5a18-4264-101a-8c59-08002b2f8426"] = "nspi",
    ["2f5f3220-c126-1076-b549-074d078619da"] = "nddeapi",
    ["3919286a-b10c-11d0-9ba8-00c04fd92ef5"] = "dssetup",
    ["f309ad18-d86a-11d0-a075-00c04fb68820"] = "IWbemLevel1Login",
    ["12345778-1234-abcd-ef00-0123456789ac"] = "samr",
    ["e1af8308-5d1f-11c9-91a4-08002b14a0fa"] = "epmapper",
    ["378e52b0-c0a9-11cf-822d-00aa0051e40f"] = "sasec",
    ["afa8bd80-7d8a-11c9-bef4-08002b102989"] = "mgmt",
    ["12345678-1234-abcd-ef00-0123456789ab"] = "spoolss",
    ["a4f1db00-ca47-1067-b31f-00dd010662da"] = "exchange_mapi",
    ["894de0c0-0d55-11d3-a322-00c04fa321a1"] = "InitShutdown",
    ["ae33069b-a2a8-46ee-a235-ddfd339be281"] = "IRPCRemoteObject",
    ["f5cc59b4-4264-101a-8c59-08002b2f8426"] = "FrsRpc",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d6"] = "dhcpcsvc6",
    ["d4781cd6-e5d3-44df-ad94-930efe48a887"] = "IWbemLoginClientID",
    ["3dde7c30-165d-11d1-ab8f-00805f14db40"] = "BackupKey",
    ["d6d70ef0-0e3b-11cb-acc3-08002b1d29c3"] = "NsiS",
    ["00000143-0000-0000-c000-000000000046"] = "IRemUnknown2",
    ["906b0ce0-c70b-1067-b317-00dd010662da"] = "IXnRemote",
    ["4590f812-1d3a-11d0-891f-00aa004b2e24"] = "IWbemClassObject unmarshaler",
    ["9a653086-174f-11d2-b5f9-00104b703efd"] = "IWbemClassObject interface",
    ["674b6698-ee92-11d0-ad71-00c04fd8fdff"] = "IWbemContext unmarshaler",
    ["3faf4738-3a21-4307-b46c-fdda9bb8c0d5"] = "AudioSrv",
    ["3c4728c5-f0ab-448b-bda1-6ce01eb0a6d5"] = "RpcSrvDHCPC",
    ["4d9f4ab8-7d1c-11cf-861e-0020af6e7c57"] = "IActivation",
    ["83da7c00-e84f-11d2-9807-00c04f8ec850"] = "sfcapi",
    ["c49e32c7-bc8b-11d2-85d4-00105a1f8304"] = "IWbemBackupRestore interface",
    ["5a7b91f8-ff00-11d0-a9b2-00c04fb6e6fc"] = "msgsvcsend",
    ["57674cd0-5200-11ce-a897-08002b2e9c6d"] = "lls_license",
    ["000001a0-0000-0000-c000-000000000046"] = "IRemoteSCMActivator",
    ["1c1c45ee-4395-11d2-b60b-00104b703efd"] = "IWbemFetchSmartEnum interface",
    ["4fc742e0-4a10-11cf-8273-00aa004ae673"] = "netdfs",
    ["027947e1-d731-11ce-a357-000000000001"] = "IEnumWbemClassObject interface",
    ["367abb81-9844-35f1-ad32-98f038001003"] = "svcctl",
    ["c8cb7687-e6d3-11d2-a958-00c04f682e16"] = "DAV RPC SERVICE",
    ["1544f5e0-613c-11d1-93df-00c04fd7bd09"] = "exchange_rfr",
    ["0d72a7d4-6148-11d1-b4aa-00c04fb66ea0"] = "ICertProtect",
    ["2c9273e0-1dc3-11d3-b364-00105a1f8177"] = "IWbemRefreshingServices interface",
    ["4b324fc8-1670-01d3-1278-5a47bf6ee188"] = "srvsvc",
    ["50abc2a4-574d-40b3-9d66-ee4fd5fba076"] = "dnsserver",
    ["f1e9c5b2-f59b-11d2-b362-00105a1f8177"] = "IWbemRemoteRefresher interface",
    ["9556dc99-828c-11cf-a37e-00aa003240c7"] = "IWbemServices",
    ["12345678-1234-abcd-ef00-01234567cffb"] = "netlogon",
    ["8d0ffe72-d252-11d0-bf8f-00c04fd9126b"] = "IKeySvc",
    ["86d35949-83c9-4044-b424-db363231fd0c"] = "ITaskSchedulerService",
    ["91ae6020-9e3c-11cf-8d7c-00aa00c091be"] = "ICertPassage",
    ["0a74ef1c-41a4-4e06-83ae-dc74fb1cdd53"] = "idletask",
    ["c386ca3e-9061-4a72-821e-498d83be188f"] = "AudioRpc",
    ["5261574a-4572-206e-b268-6b199213b4e4"] = "AsyncEMSMDB",
    ["a359dec5-e813-4834-8a2a-ba7f1d777d76"] = "IWbemBackupRestoreEx interface",
    ["d3fbb514-0e3b-11cb-8fad-08002b1d29c3"] = "NsiC",
    ["00020400-0000-0000-c000-000000000046"] = "IID_IDispatch",
    ["00000132-0000-0000-c000-000000000046"] = "ILocalSystemActivator"
}
local reg_index = {
    r15 = 0,
    r14 = 1,
    r13 = 2,
    r12 = 3,
    r11 = 4,
    r10 = 5,
    r9 = 6,
    r8 = 7,
    rdi = 8,
    rsi = 9,
    rbp = 10,
    dumm_rsp = 11,
    rbx = 12,
    rdx = 13,
    rcx = 14,
    rax = 15,

    eax = 7,
    ecx = 6,
    edx = 5,
    ebx = 4,
    dumm_esp = 3,
    ebp = 2,
    esi = 1,
    edi = 0
}

local function NOW()
    return stdapi.time()
end

local dump_memory = function(address, size, per_line)
    local addr = ffi.cast('uint8_t*', address)
    local mem = ''
    for i = 1, size do
        mem = mem .. string.format('%02x', addr[i - 1])
        if (i % per_line) == 0 then
            DbgPrint(mem)
            mem = ''
        end
    end
end

local dump_args = function(func_name, ...)
    local tid = stdapi.GetCurrentThreadId()
    local pid = stdapi.GetCurrentProcessId()
    local msg = string.format("curr[pid=%d,tid=%d], ", pid, tid)
    msg = msg .. func_name .. '('
    for k, v in pairs {...} do

        local tmp = v
        if type(v) == "table" then

            local tb = "{"

            for _, vv in pairs(v) do

                tb = tb .. tostring(vv) .. ','

            end

            tb = tb .. "}"

            tmp = tb
        end

        msg = msg .. tostring(tmp) .. ','
    end
    msg = msg .. ')'
    print(msg)
    DbgPrint(msg)
end

local function STR_IP(ip, port)
    return tostring(string.format("%s:%s", tostring(ip), tostring(port)))
end

-- 解析 thiscall 传递，nargs 只需要关注成员方法实际参数个数即可
local function parse_thiscall_args(regs, stack, nargs)
    local stack = ffi.cast('uintptr_t*', stack)
    local args = {}
    if nargs < 1 then
        return
    end

    local _this

    if X64 then
        local regs = ffi.cast('uintptr_t*', regs)
        _this = regs[reg_index.rcx]
        local arg1 = regs[reg_index.rdx]
        local arg2 = regs[reg_index.r8]
        local arg3 = regs[reg_index.r9]

        if nargs == 1 then
            args[1] = arg1
        else
            args[1] = arg1
            args[2] = arg2
            if nargs > 2 then
                args[3] = arg3
                if nargs > 3 then
                    for i = 1, nargs - 3 do
                        args[i + 3] = stack[i - 1]
                    end
                end
            end
        end
    else
        _this = regs[reg_index.ecx]
        for i = 1, nargs do
            args[i] = stack[i - 1]
        end
    end

    return _this, args
end


local function pipe_msg(data, post_mode)

    data['ts'] = tonumber(NOW())
    data['tid'] = tonumber(stdapi.GetCurrentThreadId())
    data['pid'] = tonumber(stdapi.GetCurrentProcessId())

    local name = "Unbounded03"

    local recv_ptr
    local recv_sz = 0
    local recvd_sz

    -- local post_mode = post_mode or 0

    local ptr, sz = stdapi.pack(data)

    if  ptr and sz  then

        -- dump_args('pipe_msg',data, ptr, sz)
        -- dump_memory(ptr, sz, 16)

        if post_mode == 1 then
            -- DbgPrint(string.format("async_send=%d", stdapi.send("ncalrpc", nil, name, ffi.cast('char*', ptr), tonumber(sz))))
        
            stdapi.send("ncalrpc", nil, name, ffi.cast('char*', ptr), tonumber(sz))
        else
            -- DbgPrint(string.format("send=%d", stdapi.send("ncalrpc", nil, name, ffi.cast('char*', ptr), tonumber(sz))))
            stdapi.send("ncalrpc", nil, name, ffi.cast('char*', ptr), tonumber(sz))
        end
    end

    -- stdapi.pack_free(ptr, sz)
end

local function parse_stdcall_args(regs, stack, nargs)
    local stack = ffi.cast('uintptr_t*', stack)
    local args = {}
    if nargs < 1 then
        return
    end
    if X64 then
        local regs = ffi.cast('uintptr_t*', regs)
        local arg1 = regs[reg_index.rcx]
        local arg2 = regs[reg_index.rdx]
        local arg3 = regs[reg_index.r8]
        local arg4 = regs[reg_index.r9]
        if nargs == 1 then
            args[1] = arg1
        else
            args[1] = arg1
            args[2] = arg2
            if nargs > 2 then
                args[3] = arg3
                if nargs > 3 then
                    args[4] = arg4
                    if nargs > 4 then
                        for i = 1, nargs - 4 do
                            args[i + 4] = stack[i - 1]
                        end
                    end
                end
            end
        end
    else
        for i = 1, nargs do
            args[i] = stack[i - 1]
        end
    end
    return args
end

local function g_GetFileNameFromPath(filepath)
    local filename
    if filepath then

        if string.find(filepath, "\"") then
            filepath = string.sub(filepath, 2, #filepath - 1)
        end

        filename = string.match(filepath, ".+\\([^\\]*%.%w+)$")

    end
    return filename, filepath
end

local function WS2S(wchar_t_str)
    if not stdapi.badptr(wchar_t_str) then
        return stdapi.ws2s(ffi.cast('wchar_t*', wchar_t_str))
    end
end

local function addrofmodule(module_map, addr)
    for k, v in ipairs(module_map) do
        local ss = v[1]
        local ee = v[1] + v[2]
        if not stdapi.badptr(ffi.cast('void*', addr)) then
            if addr >= ss and addr < ee then
                local name = v[3]
                local off = addr - ss
                name = g_GetFileNameFromPath(name)
                return string.format("%s+%08X", name, tonumber(off))
            end
        end
    end
    return addr
end

local function dump_stack(regs, ctx, name)

    local deep = 0x10
    local trace = {}
    local regs = ffi.cast('uintptr_t*', regs)

    local module_map = {}

    local idx = 1

    stdapi.enumldr(function(_start, size, _path)
        local path = _path
        local start

        if not stdapi.badptr(ffi.cast('void*', _path)) then
            path = WS2S(_path)
        end

        start = ffi.cast('uintptr_t', _start)

        if X32 then
            start = tonumber(start)
        end

        module_map[idx] = {start, size, path}
        -- DbgPrint(tostring(start) ..' ' .. tostring(size) .. ' ' ..tostring(path) )
        idx = idx + 1
        return 1
    end)

    if X64 then
        trace = stdapi.stacktrace(ctx, 0, regs[reg_index.dumm_rsp], deep, 0)
        trace = ffi.cast('uint64_t*', trace)
    else
        local regs = ffi.cast('uintptr_t*', regs)
        trace = stdapi.stacktrace(ctx, 0, regs[reg_index.ebp], deep, 0)
        trace = ffi.cast('uint64_t*', trace)
    end

    local str = (name or '_') .. ' \n'
    for i = 1, deep do
        str = str .. string.format('caller_%d =%s', i, addrofmodule(module_map, trace[i - 1])) .. '\n'
    end
    DbgPrint(str)
end

local hook_CreateProcessA = function(regs, stack, ctx)
    local args_num = 10
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == 10 then
        local arg2 = ffi.cast("char *", args[2])
        dump_args('CreateProcessA', args[1], ffi.string(arg2), args[3], args[4], args[5], args[6], args[7], args[8],
            args[9], args[10])
        dump_stack(regs, ctx, 'CreateProcessA')
    end
end

local hook_winexec = function(regs, stack)
    DbgPrint("call hook_winexec\n")
    local args_num = 2
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = ffi.cast("char*", args[1])
        dump_args('WinExec', ffi.string(arg1), args[2])
    end
end

local hook_VirtualAlloc = function(regs, stack)
    local args_num = 4
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('VirtualAlloc', args[1], args[2], args[3], args[4])
    end
end

local hook_CreateThread = function(regs, stack)
    local args_num = 6
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('CreateThread', args[1], args[2], args[3], args[4], args[5], args[6])
    end
end

local hook_ReadProcessMemory = function(regs, stack)
    local args_num = 5
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('ReadProcessMemory', args[1], args[2], args[3], args[4], args[5])
    end
end

local hook_WriteProcessMemory = function(regs, stack)
    local args_num = 5
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('WriteProcessMemory', args[1], args[2], args[3], args[4], args[5])
    end
end

local hook_VirtualAllocEx = function(regs, stack)
    local args_num = 5
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('VirtualAllocEx', args[1], args[2], args[3], args[4], args[5])
    end
end

local hook_CreateProcessW = function(regs, stack)
    local args_num = 10
    local args = parse_stdcall_args(regs, stack, args_num)

    if #args == 10 then
        local arg2 = WS2S(args[2])
        dump_args('CreateProcessW', args[1], arg2, args[3], args[4], args[5], args[6], args[7], args[8], args[9],
            args[10])
    end
end

local hook_ShellExecuteA = function(regs, stack)
    local args_num = 6
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local arg2 = ffi.cast("char*", args[2])
        dump_args('ShellExecuteA', args[1], ffi.string(arg2), args[3], args[4], args[5], args[6])
    end
end

local hook_ShellExecuteW = function(regs, stack)
    local args_num = 6
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local arg2 = WS2S(args[2])
        dump_args('ShellExecuteW', args[1], arg2, args[3], args[4], args[5], args[6])
    end
end

local hook_VirtualProtectEx = function(regs, stack)
    local args_num = 5
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('VirtualProtectEx', args[1], args[2], args[3], args[4], args[5])
    end
end

local hook_VirtualProtect = function(regs, stack)
    local args_num = 4
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('VirtualProtect', args[1], args[2], args[3], args[4])
    end
end

local hook_OpenProcess = function(regs, stack)
    local args_num = 3
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('OpenProcess', args[1], args[2], args[3])
    end
end

local hook_LoadLibraryA = function(regs, stack)
    local args_num = 1
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = ffi.cast("char*", args[1])
        dump_args('LoadLibraryA', ffi.string(args[1]))
    end
end

local hook_LoadLibraryW = function(regs, stack)
    local args_num = 1
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = WS2S(args[1])
        dump_args('LoadLibraryW', arg1)
    end
end

local hook_GetProcAddress = function(regs, stack)

    local args_num = 2
    -- print('->hook_GetProcAddress')
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local arg2 = args[2]
        --[[
        if not stdapi.badptr(args[2]) then
            arg2 = ffi.string(ffi.cast('char*', args[2]))
        end
        ]]
        dump_args('GetProcAddress', args[1], arg2)
    end
    -- print('hook_GetProcAddress<-')

end

local hook_HeapCreate = function(regs, stack)
    local args_num = 3
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('HeapCreate', args[1], args[2], args[3])
    end
end

----------------------- RPC HOOK -----------------------

local function DbgStr(...)
    dump_args('', ...)
end

local function query_uuid(uuid, opnum)
    local ep = endpoint_map[uuid]
    if ep then
        opnum = dce_rpc_uuid_func[string.format("%s@%s", tostring(uuid), tostring(opnum))]
        uuid = ep
    end
    return uuid, opnum
end

local function is_nullp(x)
    return ffi.cast('void*', x) == nil
end

local function get_rpc_bindstr(handle)
    local status
    local str
    local str_ptr = ffi.new('unsigned char*[1]')

    -- DbgPrint(string.format("--> handle=%s ", tostring(handle)))

    if str_ptr then
        status = stdapi.RpcBindingToStringBindingA(handle, str_ptr)
        if status == 0 then
            if not stdapi.badptr(str_ptr[0]) then

                str = ffi.string(str_ptr[0])
                print(str)

            end
        end

        stdapi.RpcStringFree(str_ptr)
    end

    -- DbgPrint(string.format("<-- handle=%s ", tostring(handle)))

    return str
end

local function get_rpc_uuid()

    --[[
    DbgPrint("-->get_rpc_uuid IN")

    local ret_uuid = '00000000-0000-0000-0000-000000000000'

    local call_uuid = ffi.new('GUID[1]')

    local tid = ffi.new('DWORD[1]')
    local pid = ffi.new('DWORD[1]')

    if tid and pid then
        stdapi.CoGetCallerTID(tid)
        stdapi.I_RpcBindingInqLocalClientPID(nil, pid)
        DbgPrint(string.format("CALLER_PID=%d, CALLER_TID=%d", pid[0], tid[0]))
    end

    if call_uuid then
        stdapi.RpcBindingInqObject(nil, call_uuid)
        ret_uuid = uuidstr(call_uuid)
    end

    DbgPrint("<--get_rpc_uuid OUT")

    return tostring(ret_uuid)
    ]]

end

-- 获取RPC请求网络信息
local function parse_rpcmsg_addr(srv_handle)

    local ncalrpc = 0
    local status = 0
    local cli_bind = ffi.new('void*[1]')

    local buff_sz = 0x80
    local fmt = ffi.new('unsigned long[1]', {}) -- IPV4 V6
    local pbuff_sz = ffi.new('unsigned long[1]', {buff_sz})
    local buff = ffi.new('unsigned char[?]', buff_sz)

    local ipbuff_sz = 0x100
    local ipbuff = ffi.new('unsigned char[?]', buff_sz)

    local rport, lport
    local cli_str, srv_str
    local srv_ip, cli_ip

    local srv_handle = srv_handle or nil

    if cli_bind and fmt and pbuff_sz and buff and ipbuff then
        repeat

            -- 获取 client
            status = stdapi.RpcBindingServerFromClient(nil, cli_bind)
            if status == 0 then
                cli_str = get_rpc_bindstr(cli_bind[0])
            end

            -- 获取srv
            if srv_handle then
                srv_str = get_rpc_bindstr(ffi.cast('void*', srv_handle))
            end

            -- 有网络请求的获取网络请求
            status = stdapi.I_RpcServerInqRemoteConnAddress(nil, buff, pbuff_sz, fmt)

            if status == 0 then
                rport = stdapi.addr2str(ipbuff, ipbuff_sz, buff)
                if rport > 0 then
                    cli_ip = WS2S(ipbuff)
                end
            end

            pbuff_sz[0] = buff_sz
            status = stdapi.I_RpcServerInqLocalConnAddress(nil, buff, pbuff_sz, fmt)
            if status == 0 then
                lport = stdapi.addr2str(ipbuff, ipbuff_sz, buff)
                if lport > 0 then
                    srv_ip = WS2S(ipbuff)
                end
            end

            break

        until (true)

        if not stdapi.badptr(cli_bind[0]) then
            stdapi.RpcBindingFree(cli_bind)
        end
    end

    -- if ncalrpc == 0 then
    DbgPrint(string.format("remote=%s local=%s [%s:%s->%s:%s]", tostring(cli_str), tostring(srv_str), tostring(cli_ip),
        tostring(rport), tostring(srv_ip), tostring(lport)))
    -- end


    if string.find(tostring(cli_str), 'ncacn_ip_tcp:') then
        local msg = {
            ['t'] = 'RPC',
            ['raddr'] = STR_IP(cli_ip, rport),
            ['laddr'] = STR_IP(srv_ip, lport),
        }
        pipe_msg(msg, 1)
    end

    return ncalrpc, {
        rip = cli_ip,
        lip = srv_ip,
        rport = rport,
        lport = lport,
        cbind = cli_str,
        sbind = srv_str
    }
end

local function test_RpcServerInqCallAttributesA()
    local rpc_attr = ffi.new('RPC_CALL_ATTRIBUTES_V2_A', {})
    local srv_bind, cli_bind
    local opnum
    local guid
    local uuid

    print('rpc_attr =', rpc_attr)
    if rpc_attr then
        rpc_attr.Version = 2
        rpc_attr.Flags = 4 -- RPC_QUERY_SERVER_PRINCIPAL_NAME | RPC_QUERY_CLIENT_PRINCIPAL_NAME
        local status = stdapi.RpcServerInqCallAttributesA(nil, ffi.cast('void*', rpc_attr))
        print('status =', status)

        local sz_buff = 256

        local srv_buff = ffi.new('char[?]', sz_buff)
        local cli_buff = ffi.new('char[?]', sz_buff)

        rpc_attr.ServerPrincipalName = ffi.cast('unsigned char*', srv_buff)
        rpc_attr.ClientPrincipalName = ffi.cast('unsigned char*', cli_buff)

        rpc_attr.ClientPrincipalNameBufferLength = sz_buff
        rpc_attr.ServerPrincipalNameBufferLength = sz_buff

        if status == 0 then
            srv_bind = ffi.string(rpc_attr.ServerPrincipalName)
            cli_bind = ffi.string(rpc_attr.ClientPrincipalName)

            uuid = uuidstr(rpc_attr.InterfaceUuid)
            opnum = rpc_attr.OpNum

            DbgPrint(string.format("test_RpcServerInqCallAttributesA, SRV=%s CLI=%s UUID=%s op=%s", tostring(srv_bind),
                tostring(cli_bind), tostring(uuid), tostring(opnum)))
        else
            DbgPrint(string.format("test_RpcServerInqCallAttributesA Failed=%s %d %d  | %s %s ", tostring(status),
                rpc_attr.ClientPrincipalNameBufferLength, rpc_attr.ServerPrincipalNameBufferLength,
                rpc_attr.ServerPrincipalName, rpc_attr.ClientPrincipalName))
        end

        rpc_attr.ServerPrincipalName = nil
        rpc_attr.ClientPrincipalName = nil
        srv_buff = nil
        cli_buff = nil
    end
end

local rpc_dyn_hook = function(InterfaceId, op_num, rountie)
    local stub = string.format("%s::%s", InterfaceId, op_num)
    local lua_stub = hook.hook_name[stub]

    if rountie and lua_stub then
        DbgPrint(string.format("try  %s %s %s %s %s", tostring(InterfaceId), tostring(op_num), tostring(rountie),
            tostring(stub), tostring(lua_stub)))
        local status = stdapi.check_hook(rountie)
        if not status then
            status = install_hookname(rountie, stub)
            DbgPrint(string.format("install %s hook = %s", tostring(stub), tostring(status)))
        else
            DbgPrint(string.format(" %s has hooked", stub))
        end
    end
end

local function parse_rpcmsg_args(rpc_msg)
    if not stdapi.badptr(rpc_msg) then
        local op_num = rpc_msg.ProcNum
        local DataRepresentation = rpc_msg.DataRepresentation
        local rountie = nil
        local rpc_rountie = 'Null'
        local rpcitf = ffi.cast('PRPC_SERVER_INTERFACE', rpc_msg.RpcInterfaceInformation)

        local handle

        if not stdapi.badptr(rpc_msg.Handle) then
            handle = rpc_msg.Handle
        end

        --DbgPrint(string.format("DataRepresentation=%08X", DataRepresentation))

        parse_rpcmsg_addr(handle)

        if rpcitf and not stdapi.badptr(rpcitf) then
            local InterfaceId = uuidstr(rpcitf.InterfaceId.SyntaxGUID)
            InterfaceId, op_num = query_uuid(InterfaceId, op_num)
            local rpc_call_number = 0

            -- 0x8A885D04

            if rpcitf.TransferSyntax.SyntaxGUID.Data1 == 0x8A885D04 then
                -- NDR

            else
                -- NDR64
            end

            -- 这里的COM调用解析不一定都适用
            if not stdapi.badptr(rpcitf.DispatchTable) then
                -- rpc_call_number = rpcitf.DispatchTable.DispatchTableCount

                -- if rpc_msg.ProcNum < rpc_call_number then
                rpc_rountie = rpcitf.DispatchTable.DispatchTable[rpc_msg.ProcNum]
                if not stdapi.badptr(rpcitf.InterpreterInfo) and not stdapi.badptr(rpcitf.InterpreterInfo.DispatchTable) then
                    rountie = ffi.cast('void*', rpcitf.InterpreterInfo.DispatchTable[rpc_msg.ProcNum])
                end
                -- end
            end

            if rountie then
                -- 动态 RPC hook 不一定找的到
                rpc_dyn_hook(InterfaceId, op_num, rountie)
            end

            DbgPrint(string.format("interface:%s op=%s rpc_rountie=%s rountie=%s", InterfaceId, tostring(op_num),
                tostring(rpc_rountie), tostring(rountie)))
        end
    end
end

local function parse_rpcmsg(rpc_msg)
    --DbgPrint("-->parse_rpcmsg IN")
    parse_rpcmsg_args(rpc_msg)
    --DbgPrint("<--parse_rpcmsg OUT")
end

local function hook_RPCSS_RemoteCreateInstance(regs, stack)
    local args_num = 6
    local caller = get_rpc_uuid()
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('RemoteCreateInstance', string.format("CALL_ID=%s", caller), args[1], args[2], args[3], args[4],
            args[5], args[6])
    end
end

local hook_Ndr64AsyncServerCall64 = function(regs, stack)
    local args_num = 1
    local caller = get_rpc_uuid()
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local rpc_msg = ffi.cast('PRPC_MESSAGE', args[1])
        parse_rpcmsg(rpc_msg)
        dump_args('Ndr64AsyncServerCall64', string.format("CALL_ID=%s", caller), args[1])
    end
end

local hook_Ndr64AsyncServerCallAll = function(regs, stack)
    local args_num = 1
    local caller = get_rpc_uuid()
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local rpc_msg = ffi.cast('PRPC_MESSAGE', args[1])
        parse_rpcmsg(rpc_msg)
        dump_args('Ndr64AsyncServerCallAll', string.format("CALL_ID=%s", caller), args[1])
    end

end

local hook_NdrAsyncServerCall = function(regs, stack)
    local args_num = 1
    local caller = get_rpc_uuid()
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local rpc_msg = ffi.cast('PRPC_MESSAGE', args[1])
        parse_rpcmsg(rpc_msg)
        dump_args('NdrAsyncServerCall', string.format("CALL_ID=%s", caller), args[1])
    end

end
-- handle(OLEAUT32!CreateErrorInfo+0x76c) CRpcChannelBuffer OLE_MESSAGE 
-- COM 调用需要解 CRpcChannelBuffer

--[[

	参数2::(参数3)
]]

local hook_NdrStubCall2 = function(regs, stack)
    local args_num = 4
    local caller = get_rpc_uuid()
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local rpc_msg = ffi.cast('PRPC_MESSAGE', args[3])
        parse_rpcmsg(rpc_msg)
        dump_args('NdrStubCall2', string.format("CALL_ID=%s", caller), args[1], args[2], args[3], args[4])
    end
end

local hook_NdrServerCallAll = function(regs, stack)
    local args_num = 1
    local caller = get_rpc_uuid()
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local rpc_msg = ffi.cast('PRPC_MESSAGE', args[1])
        parse_rpcmsg(rpc_msg)
        dump_args('NdrServerCallAll', string.format("CALL_ID=%s", caller), args[1])
    end

end

local hook_NdrServerCallNdr64 = function(regs, stack)
    local args_num = 1
    local caller = get_rpc_uuid()
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local rpc_msg = ffi.cast('PRPC_MESSAGE', args[1])
        parse_rpcmsg(rpc_msg)
        dump_args('NdrServerCallNdr64', string.format("CALL_ID=%s", caller), args[1])
    end
end

---------------------------- 远程服务创建 ------------------------------
--[[
DWORD
RChangeServiceConfigA(
  SC_RPC_HANDLE   hService,
  DWORD           dwServiceType,
  DWORD           dwStartType,
  DWORD           dwErrorControl,
  LPSTR           lpBinaryPathName,
  LPSTR           lpLoadOrderGroup,
  LPDWORD         lpdwTagId,
  LPBYTE          lpDependencies,
  DWORD           dwDependSize,
  LPSTR           lpServiceStartName,
  LPBYTE          EncryptedPassword,
  DWORD           PasswordSize,
  LPSTR           lpDisplayName
    )
	
	1: kd> kp
 # Child-SP          RetAddr               Call Site
00 00000000`02cceef8 000007fe`ff64e845     services!RChangeServiceConfigA
01 00000000`02ccef00 000007fe`ff643e5f     RPCRT4!Invoke+0x65
02 00000000`02ccefb0 000007fe`ff64080d     RPCRT4!NdrStubCall2+0x337
03 00000000`02ccf5d0 000007fe`ff6425b4     RPCRT4!NdrServerCall2+0x1d
04 00000000`02ccf600 000007fe`ff642416     RPCRT4!DispatchToStubInCNoAvrf+0x14
05 00000000`02ccf630 000007fe`ff63b03e     RPCRT4!RPC_INTERFACE::DispatchToStubWorker+0x146
06 00000000`02ccf750 000007fe`ff63ae9f     RPCRT4!OSF_SCALL::DispatchHelper+0x15e
07 00000000`02ccf870 000007fe`ff6818ca     RPCRT4!OSF_SCALL::ProcessReceivedPDU+0x36b
08 00000000`02ccf900 000007fe`ff62f6ab     RPCRT4!OSF_SCALL::BeginRpcCall+0x12a
09 00000000`02ccf930 000007fe`ff63ac33     RPCRT4!OSF_SCONNECTION::ProcessReceiveComplete+0x25e
0a 00000000`02ccf9f0 000007fe`fd659c0f     RPCRT4!CO_ConnectionThreadPoolCallback+0x123
0b 00000000`02ccfaa0 00000000`774b5fef     KERNELBASE!BasepTpIoCallback+0x4b
0c 00000000`02ccfae0 00000000`77559934     ntdll!TppIopExecuteCallback+0x1ff
0d 00000000`02ccfb90 00000000`7735570d     ntdll!TppWorkerThread+0x554
0e 00000000`02ccfe20 00000000`774b385d     kernel32!BaseThreadInitThunk+0xd
0f 00000000`02ccfe50 00000000`00000000     ntdll!RtlUserThreadStart+0x1d
]]

local hook_svcctl_ChangeServiceConfigA = function(regs, stack)
    local args_num = 13
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        local path = ffi.string(ffi.cast('char*', args[5]))
        local localcall, rpc = parse_rpcmsg_addr()
        dump_args('ChangeServiceConfigA', args[1], path, STR_IP(rpc.rip, rpc.rport))
    
        local msg = {
            ['t'] = 'SRV',
            ['c'] = {
                'ChangeServiceConfigA', path, STR_IP(rpc.rip, rpc.rport)
            }
        }
        pipe_msg(msg)

    end
end

local hook_svcctl_ChangeServiceConfigW = function(regs, stack)
    local args_num = 13
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        -- local bin = ffi.string(args[5])
        -- bin = WS2S(bin)
        dump_args('ChangeServiceConfigW', args[1], args[5])
        local msg = {
            ['t'] = 'SRV',
            ['c'] = {
                'ChangeServiceConfigW', args[1], args[5]
            }
        }
        pipe_msg(msg)
    end
end

local hook_svcctl_CreateServiceW = function(regs, stack)
    local args_num = 16
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        -- local name = ffi.string(args[2])
        -- local bin = ffi.string(args[5])

        -- name = WS2S(name)
        -- bin = WS2S(bin)

        dump_args('CreateServiceW', args[1], args[2])

        local msg = {
            ['t'] = 'SRV',
            ['c'] = {
                'CreateServiceW', args[1], args[5]
            }
        }
        pipe_msg(msg)
    end
end
--[[
DWORD
RCreateServiceA(
	SC_RPC_HANDLE   hSCManager,
	LPSTR           lpServiceName,
	LPSTR           lpDisplayName,
	DWORD           dwDesiredAccess,
	DWORD           dwServiceType,
	DWORD           dwStartType,
	DWORD           dwErrorControl,
	LPSTR           lpBinaryPathName,
	LPSTR           lpLoadOrderGroup,
	LPDWORD         lpdwTagId,
	LPBYTE          lpDependencies,
	DWORD           dwDependSize,
	LPSTR           lpServiceStartName,
	LPBYTE          EncryptedPassword,
	DWORD           PasswordSize,
	LPSC_RPC_HANDLE lpServiceHandle
    )

]]
local hook_svcctl_CreateServiceA = function(regs, stack)
    local args_num = 16
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('CreateServiceA', args[1], args[2])
    end
end
----------------------------------------------------------------------

local function lpc_getclient()

    local pr = ffi.new('HANDLE[1]')
    local th = ffi.new('HANDLE[1]')

    local ac_THREAD_QUERY_LIMITED_INFORMATION = 0x0800 -- THREAD_QUERY_LIMITED_INFORMATION
    local ac_PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
    local pid, tid

    if pr and th then
        local status = 0

        status = stdapi.I_RpcOpenClientThread(nil, ac_THREAD_QUERY_LIMITED_INFORMATION, ffi.cast('HANDLE*', pr))
        if status == 0 then
            tid = stdapi.GetThreadId(pr[0])
        end

        DbgPrint(string.format("I_RpcOpenClientThread=%d", status))

        status = stdapi.I_RpcOpenClientProcess(nil, ac_PROCESS_QUERY_LIMITED_INFORMATION, ffi.cast('HANDLE*', th))
        if status == 0 then
            pid = stdapi.GetProcessId(th[0])
        end

        DbgPrint(string.format("I_RpcOpenClientProcess=%d", status))

        if not is_nullp(pr[0]) then
            stdapi.ntclose(pr[0])
        end

        if not is_nullp(th[0]) then
            stdapi.ntclose(th[0])
        end
    end

    return pid, tid
end

--[[

https://learn.microsoft.com/en-us/windows/win32/api/rpcndr/ns-rpcndr-midl_stub_desc

typedef struct _MIDL_STUB_DESC
    {
    void  *    RpcInterfaceInformation;
    void  *    ( __RPC_API * pfnAllocate)(size_t);
    void       ( __RPC_API * pfnFree)(void  *);
    union
        {
        handle_t  *             pAutoHandle;
        handle_t  *             pPrimitiveHandle;
        PGENERIC_BINDING_INFO   pGenericBindingInfo;
        } IMPLICIT_HANDLE_INFO;
....
    } MIDL_STUB_DESC;
]]

local function parse_client_call(regs, stack, ver)

    local endpoint
    local InterfaceId
    local rpcitf
    local ptr_handle

    local args = parse_stdcall_args(regs, stack, 2)

    -- 从 PROC_STR 里面解析出来 op_num

    -- DbgPrint(string.format("ver=%d ptr_handle=%s %s %s",ver, tostring(ptr_handle), tostring(ptr_handle[0]), stdapi.badptr(ptr_handle[0])))	
    local op_num

    if ver == 3 then
        local midl_or_sub = ffi.cast('uintptr_t*', args[1])
        if not stdapi.badptr(midl_or_sub) then
            midl_or_sub = ffi.cast('uintptr_t*', midl_or_sub[0])
            rpcitf = ffi.cast('PRPC_SERVER_INTERFACE', midl_or_sub[0])
            ptr_handle = ffi.cast('uintptr_t*', midl_or_sub[3])
        end
        op_num = ffi.cast('unsigned long', args[2])
    end

    if ver == 2 then
        local midl_or_sub = ffi.cast('uintptr_t*', args[1])
        rpcitf = ffi.cast('PRPC_SERVER_INTERFACE', midl_or_sub[0])
        ptr_handle = ffi.cast('uintptr_t*', midl_or_sub[3])

        local proc_buffptr = ffi.cast('unsigned char*', args[2])
        op_num = ffi.cast('unsigned short*', proc_buffptr + 1 + 1 + 4) -- hack
        print(op_num, proc_buffptr)
        op_num = op_num[0]
    end

    if not stdapi.badptr(ptr_handle) and not stdapi.badptr(rpcitf) and not stdapi.badptr(ptr_handle[0]) and
        stdapi.badptr(rpcitf.InterfaceId) then
        InterfaceId = uuidstr(rpcitf.InterfaceId.SyntaxGUID)
        InterfaceId, op_num = query_uuid(InterfaceId, op_num)
        endpoint = get_rpc_bindstr(ffi.cast('void*', ptr_handle[0]))
        return endpoint, InterfaceId, op_num
    end

end
--[[

	CLIENT_CALL_RETURN RPC_VAR_ENTRY NdrClientCall3(
	  MIDL_STUBLESS_PROXY_INFO *pProxyInfo,
	  unsigned long            nProcNum,
	  void                     *pReturnValue,
	  ...                      
	);

/*
 * Stubless object proxy information structure.
 */
typedef struct _MIDL_STUBLESS_PROXY_INFO
    {
    PMIDL_STUB_DESC                     pStubDesc;
    PFORMAT_STRING                      ProcFormatString;
    const unsigned short            *   FormatStringOffset;
    PRPC_SYNTAX_IDENTIFIER              pTransferSyntax;
    ULONG_PTR                           nCount;
    PMIDL_SYNTAX_INFO                   pSyntaxInfo;
    } MIDL_STUBLESS_PROXY_INFO;
	
]]

--[[

COM msg hook

STDMETHODIMP CCtxComChnl::ContextInvoke(RPCOLEMESSAGE *pMessage,
                                        IRpcStubBuffer *pStub,
                                        IPIDEntry *pIPIDEntry,
                                        DWORD *pdwFault)


NdrServerCall2 -> OLE!void __fastcall ThreadInvoke(_RPC_MESSAGE *pMessage)

]]

local function hook_NdrClientCall3(regs, stack)
    local caller = get_rpc_uuid()
    local endpoint, InterfaceId, op_num = parse_client_call(regs, stack, 3)
    dump_args('NdrClientCall3', string.format("CALL_ID=%s", caller), endpoint, InterfaceId, op_num)
end

local function hook_NdrClientCall2(regs, stack)
    local caller = get_rpc_uuid()
    local endpoint, InterfaceId, op_num = parse_client_call(regs, stack, 2)
    dump_args('NdrClientCall2', string.format("CALL_ID=%s", caller), endpoint, InterfaceId, op_num)
end

local function hook_wmi_GetObjectAsync(regs, stack)
    local args_num = 4
    local caller = get_rpc_uuid()
    local _this, args = parse_thiscall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = WS2S(args[1])
        dump_args('wmi::GetObjectAsync', string.format("CALL_ID=%s", caller), arg1, args[2], args[3], args[4])
    end
end


---------------------------- 远程WMI创建 -----------------------------
-- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-wmi/49ee7019-aa2d-49ef-948a-05c468e37d31

--[[

virtual HRESULT STDMETHODCALLTYPE GetObjectAsync( 
	/* [in] */ __RPC__in const BSTR strObjectPath,
	/* [in] */ long lFlags,
	/* [in] */ __RPC__in_opt IWbemContext *pCtx,
	/* [in] */ __RPC__in_opt IWbemObjectSink *pResponseHandler) = 0;
	
	virtual HRESULT STDMETHODCALLTYPE PutInstanceAsync( 
	/* [in] */ __RPC__in_opt IWbemClassObject *pInst,
	/* [in] */ long lFlags,
	/* [in] */ __RPC__in_opt IWbemContext *pCtx,
	/* [in] */ __RPC__in_opt IWbemObjectSink *pResponseHandler) = 0;

virtual HRESULT STDMETHODCALLTYPE DeleteInstanceAsync( 
	/* [in] */ __RPC__in const BSTR strObjectPath,
	/* [in] */ long lFlags,
	/* [in] */ __RPC__in_opt IWbemContext *pCtx,
	/* [in] */ __RPC__in_opt IWbemObjectSink *pResponseHandler) = 0;

virtual HRESULT STDMETHODCALLTYPE CreateInstanceEnumAsync( 
	/* [in] */ __RPC__in const BSTR strFilter,
	/* [in] */ long lFlags,
	/* [in] */ __RPC__in_opt IWbemContext *pCtx,
	/* [in] */ __RPC__in_opt IWbemObjectSink *pResponseHandler) = 0;

virtual HRESULT STDMETHODCALLTYPE ExecQueryAsync( 
	/* [in] */ __RPC__in const BSTR strQueryLanguage,
	/* [in] */ __RPC__in const BSTR strQuery,
	/* [in] */ long lFlags,
	/* [in] */ __RPC__in_opt IWbemContext *pCtx,
	/* [in] */ __RPC__in_opt IWbemObjectSink *pResponseHandler) = 0;

virtual HRESULT STDMETHODCALLTYPE ExecMethodAsync( 
	/* [in] */ __RPC__in const BSTR strObjectPath,
	/* [in] */ __RPC__in const BSTR strMethodName,
	/* [in] */ long lFlags,
	/* [in] */ __RPC__in_opt IWbemContext *pCtx,
	/* [in] */ __RPC__in_opt IWbemClassObject *pInParams,
	/* [in] */ __RPC__in_opt IWbemObjectSink *pResponseHandler) = 0;
        
	1, 下面都是成员方法hook，需要注意了


	COM 串链
	2, NdrClientCall2 解析里面的 pGenericBindingInfo bind RpcBindingToStringBindingA ,查找对端endpoint

]]

local function hook_wmi_PutInstanceAsync(regs, stack)
    local args_num = 4
    local caller = get_rpc_uuid()

    local _this, args = parse_thiscall_args(regs, stack, args_num)
    if #args == args_num then
        local wmi_args = stdapi.enumwo(ffi.cast('void*', args[1]))
        dump_args('wmi::PutInstanceAsync', string.format("CALL_ID=%s", caller), wmi_args)
    end
end
local function hook_wmi_DeleteInstanceAsync(regs, stack)
    local args_num = 4
    local caller = get_rpc_uuid()

    local _this, args = parse_thiscall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = WS2S(args[1])
        dump_args('wmi::DeleteInstanceAsync', string.format("CALL_ID=%s", caller), arg1, args[2], args[3], args[4])
    end
end
local function hook_wmi_CreateInstanceEnumAsync(regs, stack)
    local args_num = 4
    local caller = get_rpc_uuid()

    local _this, args = parse_thiscall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = WS2S(args[1])
        dump_args('wmi::CreateInstanceEnumAsync', string.format("CALL_ID=%s", caller), arg1, args[2], args[3], args[4])
    end
end
local function hook_wmi_ExecQueryAsync(regs, stack)
    local args_num = 5
    local caller = get_rpc_uuid()

    local _this, args = parse_thiscall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = WS2S(args[1])
        local arg2 = WS2S(args[2])

        local localcall, rpc = parse_rpcmsg_addr()

        dump_args('wmi::ExecQueryAsync', string.format("CALL_ID=%s", caller), arg1, arg2, args[3], args[4], args[5])
    end
end
local function hook_wmi_ExecMethodAsync(regs, stack)
    local args_num = 6

    local caller = get_rpc_uuid()

    local _this, args = parse_thiscall_args(regs, stack, args_num)
    if #args == args_num then
        local arg1 = WS2S(args[1])
        local arg2 = WS2S(args[2])
        local wmi_args = stdapi.enumwo(ffi.cast('void*', args[5]))
        -- test_RpcServerInqCallAttributesA()
        local cli_pid, cli_tid = lpc_getclient()
        DbgPrint(string.format("wmi::ExecMethodAsync_client_info %s %s", tostring(cli_pid), tostring(cli_tid)))
        dump_args('wmi::ExecMethodAsync', string.format("CALL_ID=%s", caller), arg1, arg2, args[3], args[4], wmi_args, args[6])

        local msg = {
            ['t'] = 'WMI',
            ['c'] = {'wmi::ExecMethod', arg1, arg2, tonumber(args[3]), tonumber(args[4]), wmi_args, tonumber(args[6])},
        }
        pipe_msg(msg)

    end
end

----------------------------------------------------------------------

local function hook_disp_GetTypeInfoCount(regs, stack)
    local args_num = 1
    local _this, args = parse_thiscall_args(regs, stack, args_num)
    dump_args('disp::GetTypeInfoCount')
end

local function hook_disp_GetTypeInfo(regs, stack)
    local args_num = 3
    local _this, args = parse_thiscall_args(regs, stack, args_num)
    dump_args('disp::GetTypeInfo')
end

local function hook_disp_GetIDsOfNames(regs, stack)
    local args_num = 5
    local _this, args = parse_thiscall_args(regs, stack, args_num)
    dump_args('disp::GetIDsOfNames')
end

--[[

	STDMETHOD(Invoke)(
		_In_ DISPID dispidMember,
		_In_ REFIID riid,
		_In_ LCID lcid,
		_In_ WORD wFlags,
		_In_ DISPPARAMS* pdispparams,
		_Out_opt_ VARIANT* pvarResult,
		_Out_opt_ EXCEPINFO* pexcepinfo,
		_Out_opt_ UINT* puArgErr)
            
    /* Flags for IDispatch::Invoke */
    #define DISPATCH_METHOD         0x1
    #define DISPATCH_PROPERTYGET    0x2
    #define DISPATCH_PROPERTYPUT    0x4
    #define DISPATCH_PROPERTYPUTREF 0x8
]]
local function hook_disp_Invoke(regs, stack)
    local args_num = 8


    local _this, args = parse_thiscall_args(regs, stack, args_num)

    local dispIdMember = args[1]
    local disp_type = ffi.cast('uint16_t', args[4])
    local disp_args = args[5]

    local DISPATCH_METHOD = 1

    if DISPATCH_METHOD == disp_type then
        disp_args = stdapi.enumdisp(ffi.cast('void*', disp_args))
    end

    dump_args('disp::Invoke', dispIdMember, disp_type, disp_args)
end

local function hook_disp_Open(regs, stack)
    local args_num = 1
    local _this, args = parse_thiscall_args(regs, stack, args_num)
    dump_args('disp::Open')
end
local function hook_disp_FileRun(regs, stack)
    -- local args_num = 0
    -- local _this, args = parse_thiscall_args(regs, stack, args_num)
    dump_args('disp::FileRun')
end
--[[
        DECLSPEC_XFGVIRT(IShellDispatch2, ShellExecute)
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE *ShellExecute )( 
            __RPC__in IShellDispatch2 * This,
            /* [in] */ __RPC__in BSTR File,
            /* [optional][in] */ VARIANT vArgs,
            /* [optional][in] */ VARIANT vDir,
            /* [optional][in] */ VARIANT vOperation,
            /* [optional][in] */ VARIANT vShow);
        
]]
local function hook_disp_ShellExecuteW(regs, stack)
    local args_num = 5
    local _this, args = parse_thiscall_args(regs, stack, args_num)
    
    local arg1 = WS2S(args[1])
    local arg2 = stdapi.dump_var(args[2])
    local arg3 = stdapi.dump_var(args[3])
    local arg4 = stdapi.dump_var(args[4])
    local arg5 = stdapi.dump_var(args[5])
    
    dump_args('disp::ShellExecuteW', arg1, arg2, arg3, arg4, arg5)

    local msg = {
        ['t'] = 'DCOM',
        ['c'] = {'disp::ShellExecuteW', arg1, arg2, arg3, arg4, arg5},
    }

    pipe_msg(msg)

end

--[[
    NTSYSCALLAPI
NTSTATUS
NTAPI
NtAlpcSendWaitReceivePort(
    _In_ HANDLE PortHandle,
    _In_ ULONG Flags,
    _In_reads_bytes_opt_(SendMessage->u1.s1.TotalLength) PPORT_MESSAGE SendMessage,
    _Inout_opt_ PALPC_MESSAGE_ATTRIBUTES SendMessageAttributes,
    _Out_writes_bytes_to_opt_(*BufferLength, *BufferLength) PPORT_MESSAGE ReceiveMessage,
    _Inout_opt_ PSIZE_T BufferLength,
    _Inout_opt_ PALPC_MESSAGE_ATTRIBUTES ReceiveMessageAttributes,
    _In_opt_ PLARGE_INTEGER Timeout
    );
]]
local function hook_NtAlpcSendWaitReceivePort(regs, stack)
    local args_num = 8
    local args = parse_stdcall_args(regs, stack, args_num)

    if #args == args_num then
        local h = args[1]
        local Flags = args[2]
        local send_msg = args[3] -- PPORT_MESSAGE
        local recv_msg = args[5]
        
        local s_pid , r_pid
        local s_tid , r_tid
        local s_msgid, r_msgid

        send_msg = ffi.cast('PPORT_MESSAGE', send_msg)

        if not stdapi.badptr(send_msg) then
            s_pid = ffi.cast('uintptr_t', send_msg.ClientId.UniqueProcess)  -- 里面是对端的 PID 个 TID
            s_tid = ffi.cast('uintptr_t', send_msg.ClientId.UniqueThread)
            s_msgid = ffi.cast('unsigned long', send_msg.MessageId)
        end

        recv_msg = ffi.cast('PPORT_MESSAGE', recv_msg)

        if not stdapi.badptr(recv_msg) then
            r_pid = ffi.cast('uintptr_t', recv_msg.ClientId.UniqueProcess)
            r_tid = ffi.cast('uintptr_t', recv_msg.ClientId.UniqueThread)
            r_msgid = ffi.cast('unsigned long', recv_msg.MessageId)
        end

        -- dump_args('NtAlpcSendWaitReceivePort', h, Flags, {s_pid, s_tid, s_msgid}, { r_pid, r_tid, r_msgid})
        
        local msg = {
            ['t'] = 'ALPC',
            ['dpid'] = tonumber(s_pid),
            ['dtid'] = tonumber(s_tid),
        }

        pipe_msg(msg)
    
    end

end

local hook_InternetOpenA = function (regs, stack)
    local args_num = 5
    local args = parse_stdcall_args(regs, stack, args_num)

    local arg1 = ffi.string(ffi.cast('char*', args[1]))
    dump_args('InternetOpenA', ffi.string(arg1))
end

local hook_InternetOpenW = function (regs, stack)
    local args_num = 5
    local args = parse_stdcall_args(regs, stack, args_num)

    local arg1 = WS2S(args[1])
    dump_args('InternetOpenW', arg1)

end

local hook_InternetOpenUrlA = function(regs, stack)
    local args_num = 6
    local args = parse_stdcall_args(regs, stack, args_num)

    local arg2 = ffi.string(ffi.cast('char*', args[2]))
    dump_args('InternetOpenUrlA', arg2)

end

local hook_InternetOpenUrlW = function(regs, stack)
    local args_num = 6
    local args = parse_stdcall_args(regs, stack, args_num)
    local arg2 = WS2S(args[2])
    dump_args('InternetOpenUrlW', arg2)
end

local hook_InternetConnectA = function(regs, stack)
    local args_num = 8
    local args = parse_stdcall_args(regs, stack, args_num)

    local arg2 = ffi.string(ffi.cast('char*', args[2]))
    dump_args('InternetConnectA', arg2, args[3])
end

local hook_InternetConnectW = function(regs, stack)
    local args_num = 8
    local args = parse_stdcall_args(regs, stack, args_num)
    local arg2 = WS2S(args[2])
    dump_args('InternetConnectW', arg2, args[3])
end

local hook_InternetCrackUrlA = function(regs, stack)
    local args_num = 4
    local args = parse_stdcall_args(regs, stack, args_num)
    local arg1 = ffi.string(ffi.cast('char*', args[1]))
    dump_args('InternetCrackUrlA', arg1)
end

local hook_InternetCrackUrlW = function(regs, stack)
    local args_num = 4
    local args = parse_stdcall_args(regs, stack, args_num)
    local arg1 = WS2S(args[1])
    dump_args('InternetCrackUrlW', arg1)
end

local hook_InternetCreateUrlA = function(regs, stack)
    local args_num = 4
    local args = parse_stdcall_args(regs, stack, args_num)

    dump_args('InternetCreateUrlA')
end

local hook_InternetCreateUrlW = function(regs, stack)
    local args_num = 4
    local args = parse_stdcall_args(regs, stack, args_num)

    dump_args('InternetCreateUrlW')
end


----------------- 进程注入检测 -----------------

local check_hook_addr_args = function(hproc, thread_start, thread_args)
        -- 判断起始位置是否 LoadLibraryA, LoadLibraryW

        -- 判断起始位置内存属性

end


local hook_CreateRemoteThread = function(regs, stack, ctx)
    local args_num = 7
    -- 获取函数预调用参数
    local args = parse_stdcall_args(regs, stack, args_num)
    if #args == args_num then
        dump_args('CreateRemoteThread', args[1], args[2], args[3], args[4], args[5], args[6], args[7])
        local buflen = ffi.new("uintptr_t[1]") -- 搞个指针出来
        local alloc_size = 0x1000

        dump_stack(regs, ctx)

        -- 动态申请内存，保存shellcode
        local p = ffi.gc(stdapi.malloc(alloc_size), stdapi.free)
        local target_addr = bit.band(args[4], 0xFFFFFFFFFFFFF000)

        -- 查看远程执行的内存数据是什么
        -- 通过ReadProcessMemory把远程准备执行的数据转储下来
        print(args[1], args[4], p, alloc_size, buflen)
        if ffi.C.ReadProcessMemory(ffi.cast('HANDLE', args[1]), ffi.cast('intptr_t', target_addr),
            ffi.cast('intptr_t', p), ffi.cast('intptr_t', alloc_size), buflen) then
            DbgPrint('-Dump ShellCode BEG-')
            -- 可以进一步判断是什么类型shellcode
            dump_memory(p, alloc_size, 64)
            DbgPrint('-Dump ShellCode END-')
        end
        -- 通过lua gc机制释放内存
        p = nil
    end
end


local ReflectiveDllInjection = function(regs, stack, ctx)

    
    
end


local hook_NtCreateThreadEx = function(regs, stack, ctx)

end

local hook_NtCreateUserProcess = function(regs, stack, ctx)

end

local hook_QueueUserAPC =function(regs, stack, ctx)

end

local hook_SetWindowsHookEx = function(regs, stack, ctx)
    
end

local hook_SuspendInjectResume = function(regs, stack, ctx)

end

local hook_ResumeThread = function(regs, stack, ctx)
    -- 防止挂起线程绕过检测

end

hook.hook_addr = {
    [tostring(ffi.cast('intptr_t*', ntapi.CreateProcessA))] = hook_CreateProcessA,
    [tostring(ffi.cast('intptr_t*', ntapi.WinExec))] = hook_winexec,
    [tostring(ffi.cast('intptr_t*', ntapi.VirtualAlloc))] = hook_VirtualAlloc,
    [tostring(ffi.cast('intptr_t*', ntapi.CreateThread))] = hook_CreateThread,
    [tostring(ffi.cast('intptr_t*', ntapi.ReadProcessMemory))] = hook_ReadProcessMemory,
    [tostring(ffi.cast('intptr_t*', ntapi.WriteProcessMemory))] = hook_WriteProcessMemory,
    [tostring(ffi.cast('intptr_t*', ntapi.VirtualAllocEx))] = hook_VirtualAllocEx,
    [tostring(ffi.cast('intptr_t*', ntapi.CreateRemoteThread))] = hook_CreateRemoteThread,
    [tostring(ffi.cast('intptr_t*', ntapi.CreateProcessW))] = hook_CreateProcessW,
    [tostring(ffi.cast('intptr_t*', ntapi.ShellExecuteA))] = hook_ShellExecuteA,
    [tostring(ffi.cast('intptr_t*', ntapi.ShellExecuteW))] = hook_ShellExecuteW,
    [tostring(ffi.cast('intptr_t*', ntapi.VirtualProtectEx))] = hook_VirtualProtectEx,
    [tostring(ffi.cast('intptr_t*', ntapi.VirtualProtect))] = hook_VirtualProtect,
    [tostring(ffi.cast('intptr_t*', ntapi.OpenProcess))] = hook_OpenProcess,
    [tostring(ffi.cast('intptr_t*', ntapi.LoadLibraryA))] = hook_LoadLibraryA,
    [tostring(ffi.cast('intptr_t*', ntapi.LoadLibraryW))] = hook_LoadLibraryW,
    [tostring(ffi.cast('intptr_t*', ntapi.GetProcAddress))] = hook_GetProcAddress,
    [tostring(ffi.cast('intptr_t*', ntapi.HeapCreate))] = hook_HeapCreate,

    -- RPC hook
    [tostring(ffi.cast('intptr_t*', ntapi.Ndr64AsyncServerCall64))] = hook_Ndr64AsyncServerCall64,
    [tostring(ffi.cast('intptr_t*', ntapi.Ndr64AsyncServerCallAll))] = hook_Ndr64AsyncServerCallAll,
    [tostring(ffi.cast('intptr_t*', ntapi.NdrAsyncServerCall))] = hook_NdrAsyncServerCall,
    [tostring(ffi.cast('intptr_t*', ntapi.NdrStubCall2))] = hook_NdrStubCall2,
    [tostring(ffi.cast('intptr_t*', ntapi.NdrServerCallAll))] = hook_NdrServerCallAll,
    [tostring(ffi.cast('intptr_t*', ntapi.NdrServerCallNdr64))] = hook_NdrServerCallNdr64,

    [tostring(ffi.cast('intptr_t*', ntapi.NtAlpcSendWaitReceivePort))] = hook_NtAlpcSendWaitReceivePort,
    -- [tostring(ffi.cast('intptr_t*', ntapi.NdrClientCall3))] = hook_NdrClientCall3,
    -- [tostring(ffi.cast('intptr_t*', ntapi.NdrClientCall2))] = hook_NdrClientCall2,

    [tostring(ffi.cast('intptr_t*',  ntapi.InternetOpenA))] = hook_InternetOpenA,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetOpenW))] = hook_InternetOpenW,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetOpenUrlA))] = hook_InternetOpenUrlA,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetOpenUrlW))] = hook_InternetOpenUrlW,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetConnectA))] = hook_InternetConnectA,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetConnectW))] = hook_InternetConnectW,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetCrackUrlA))] = hook_InternetCrackUrlA,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetCrackUrlW))] = hook_InternetCrackUrlW,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetCreateUrlA))] = hook_InternetCreateUrlA,
    [tostring(ffi.cast('intptr_t*',  ntapi.InternetCreateUrlW))] = hook_InternetCreateUrlW,
}

-- name 最长 63 个字符
hook.hook_name = {
    ["IRemoteSCMActivator::RemoteCreateInstance"] = hook_RPCSS_RemoteCreateInstance,
    ["svcctl::ChangeServiceConfigA"] = hook_svcctl_ChangeServiceConfigA,
    ["svcctl::ChangeServiceConfigW"] = hook_svcctl_ChangeServiceConfigW,
    ["svcctl::CreateServiceW"] = hook_svcctl_CreateServiceW,
    ["svcctl::CreateServiceA"] = hook_svcctl_CreateServiceA,

    ["IWbemServices::GetObjectAsync"] = hook_wmi_GetObjectAsync,
    ["IWbemServices::PutInstanceAsync"] = hook_wmi_PutInstanceAsync,
    ["IWbemServices::DeleteInstanceAsync"] = hook_wmi_DeleteInstanceAsync,
    ["IWbemServices::CreateInstanceEnumAsync"] = hook_wmi_CreateInstanceEnumAsync,
    ["IWbemServices::ExecQueryAsync"] = hook_wmi_ExecQueryAsync,
    ["IWbemServices::ExecMethodAsync"] = hook_wmi_ExecMethodAsync,

    ["IDispatch::GetTypeInfoCount"] = hook_disp_GetTypeInfoCount,
    ["IDispatch::GetTypeInfo"] = hook_disp_GetTypeInfo,
    ["IDispatch::GetIDsOfNames"] = hook_disp_GetIDsOfNames,
    ["IDispatch::Invoke"] = hook_disp_Invoke,
    ["IDispatch::Open"] = hook_disp_Open,
    ["IDispatch::FileRun"] = hook_disp_FileRun,
    ["IDispatch::ShellExecuteW"] = hook_disp_ShellExecuteW,
}


function on_callback(ctx, addr, regs, stack, name)
    local x = ffi.cast('intptr_t*', addr)

    local func = hook.hook_addr[tostring(x)]
    -- print (func, tostring(x), hook.hook_addr[tostring(x)])
    if func == nil then
        func = hook.hook_name[name]
    end

    if func then
        func(regs, stack, ctx, addr)
    end

end
