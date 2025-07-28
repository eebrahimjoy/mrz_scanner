package com.scansolutions.mrzflutterplugin

interface ScannerActivityListener {
    fun resumeScanning()

    fun closeScanner()

    fun setContinuousScanningEnabled(enabled: Boolean)

    fun setIgnoreDuplicatesEnabled(enabled: Boolean)
}