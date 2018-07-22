dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by ./scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/x86/linux-x86.conf.m4
dnl Copyright (C) 2009 - 2018 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---

CONFIG_EFI=y
CONFIG_SFI=y

dnl Memory Type Range Register support
dnl and other x86 goodies ...
dnl
CONFIG_MTRR=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_NONFATAL=y
CONFIG_X86_MCE_P4THERMAL=y
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_INTEL_IDLE=y

CONFIG_AMD_IOMMU=y
CONFIG_INTEL_IOMMU=y

CONFIG_MICROCODE_AMD=y

dnl PC Speaker for 2.5/6 kernel
CONFIG_INPUT_PCSPKR=m
CONFIG_USB_HIDINPUT_POWERBOOK=y

dnl Power management and ACPI options
dnl
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HED=y
CONFIG_ACPI_BGRT=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_DMA_ACPI=y

dnl Support for latest low level clocks, gpio, and i2c glue
dnl
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_X86_INTEL_LPSS=y
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
CONFIG_PMIC_OPREGION=y
CONFIG_INTEL_SOC_PMIC=y

dnl The default is to support those old ISA boxes.
dnl A target might get rid of it.
dnl
CONFIG_ISA=y
CONFIG_ISAPNP=y
CONFIG_PNPBIOS=y

CONFIG_PNP=y

dnl The default x86 frame-buffer fallback
dnl
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
CONFIG_VGA_SWITCHEROO=y
CONFIG_FB_GEODE=y
