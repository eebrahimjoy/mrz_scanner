package com.scansolutions.mrzflutterplugin;

import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.graphics.RectF;
import android.os.Bundle;
import android.view.Display;
import android.view.Gravity;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.scansolutions.mrzscannerlib.MRZResultModel;
import com.scansolutions.mrzscannerlib.MRZScanner;
import com.scansolutions.mrzscannerlib.MRZScannerListener;
import com.scansolutions.mrzscannerlib.ScannerType;

import androidx.appcompat.app.AppCompatActivity;

public class ScannerActivity extends AppCompatActivity implements MRZScannerListener {

    static  Float sZoomFactor = 0f;
    static int sScannerType = 0;
    static Boolean sToggleFlash = false;
    static MRZScannerListener mrzScannerListener;
    static MRZScannerDismissedListener mrzScannerDismissed;
    //    static final String OVERLAY_IMG_NAME = "MRZ_OVERLAY_IMG.jpg";
    static RectF sPartialRect;
    static Boolean continuousScanningEnabled = false;
    private static Boolean ignoreDuplicatesEnabled = true;

    static ScannerActivityListener scannerActivityListener;
    private MRZScanner mrzScanner;

    public static void startScanner(Context context,
                                    int scannerType,
                                    float zoomFactor,
                                    Boolean toggleFlash,
                                    String base64String,
                                    RectF partialRect,
                                    MRZScannerListener listener,
                                    MRZScannerDismissedListener mrzScannerDismissedListener) {
        sPartialRect = partialRect;
        sZoomFactor = zoomFactor;
        sToggleFlash = toggleFlash;
        sScannerType = scannerType;
        mrzScannerListener = listener;
        mrzScannerDismissed = mrzScannerDismissedListener;
        Intent intent = new Intent(context, ScannerActivity.class);

//        if (base64String != null && !"".equals(base64String)) {
//            String imagePath = ScannerActivity.saveToInternalStorage(base64String, context);
//            intent.putExtra(ScannerActivity.OVERLAY_IMG_KEY, imagePath);
//        }

        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        if (sPartialRect != null) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
            Point displaySize = getDisplaySize(ScannerActivity.this);
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.gravity = Gravity.TOP | Gravity.LEFT;
            lp.x = (int) (displaySize.x * (sPartialRect.left / 100.0f));
            lp.y = (int) (displaySize.y * (sPartialRect.top / 100.0f));
            lp.horizontalMargin = 0;
            lp.verticalMargin = 0;
            lp.width = (int) (displaySize.x * (sPartialRect.right / 100.0f));
            lp.height = (int) (displaySize.y * (sPartialRect.bottom / 100.0f));
            getWindow().setAttributes(lp);
        } else {
            setTheme(R.style.Theme_AppCompat_NoActionBar);
        }

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scanner);
//        String imagePathId = getIntent().getStringExtra(OVERLAY_IMG_KEY);
//        Bitmap overlayImage = loadImageFromStorage(imagePathId);

        //    static final String OVERLAY_IMG_KEY = "MRZ_BITMAP_PATH";
        mrzScanner = (MRZScanner) getSupportFragmentManager().findFragmentById(R.id.scannerFragment);
        mrzScanner.setIgnoreDuplicates(ignoreDuplicatesEnabled);
        mrzScanner.setContinuousScanningEnabled(continuousScanningEnabled);
        MRZScanner.setZoomFactor(sZoomFactor);
        setupPartialView(mrzScanner);
        mrzScanner.setScannerType(ScannerType.values()[sScannerType]);
        mrzScanner.toggleFlash(sToggleFlash);
        if (scannerActivityListener == null)
            scannerActivityListener = new ScannerActivityListener() {
                @Override
                public void setIgnoreDuplicatesEnabled(boolean enabled) {
                    if (mrzScanner != null)
                        mrzScanner.setIgnoreDuplicates(enabled);
                }

                @Override
                public void setContinuousScanningEnabled(boolean enabled) {
                    if (mrzScanner != null)
                        mrzScanner.setContinuousScanningEnabled(enabled);
                }

                @Override
                public void closeScanner() {
                    ScannerActivity.this.finish();
                }

                @Override
                public void resumeScanning() {
                    if (mrzScanner != null) {
                        mrzScanner.resumeScanning();
                    }
                }
            };
//        mrzScanner.setCustomImageOverlay(overlayImage);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        if (sPartialRect != null) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
            Point displaySize = getDisplaySize(ScannerActivity.this);
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.gravity = Gravity.TOP | Gravity.LEFT;
            lp.x = (int) (displaySize.x * (sPartialRect.left / 100.0f));
            lp.y = (int) (displaySize.y * (sPartialRect.top / 100.0f));
            lp.horizontalMargin = 0;
            lp.verticalMargin = 0;
            lp.width = (int) (displaySize.x * (sPartialRect.right / 100.0f));
            lp.height = (int) (displaySize.y * (sPartialRect.bottom / 100.0f));
            getWindow().setAttributes(lp);
        } else {
            setTheme(R.style.Theme_AppCompat_NoActionBar);
        }
        super.onConfigurationChanged(newConfig);
    }

    private void setupPartialView(MRZScanner mrzScanner) {
        if (sPartialRect != null) {
            Point displaySize = getDisplaySize(ScannerActivity.this);
            FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) mrzScanner.getView().getLayoutParams();
            params.width = (int) (displaySize.x * (sPartialRect.right / 100.0f));
            params.height = (int) (displaySize.y * (sPartialRect.bottom / 100.0f));
            mrzScanner.getView().setLayoutParams(params);
        }
    }

    @Override
    public void successfulScanWithResult(MRZResultModel mrzResultModel) {
        mrzScannerListener.successfulScanWithResult(mrzResultModel);
        if (!continuousScanningEnabled)
            finish();
    }

    @Override
    public void successfulScanWithDocumentImage(Bitmap bitmap) {
        mrzScannerListener.successfulScanWithDocumentImage(bitmap);
        finish();
    }

    @Override
    public void successfulIdFrontImageScan(Bitmap bitmap, Bitmap bitmap1) {

    }

    @Override
    public void scanImageFailed() {
        mrzScannerListener.scanImageFailed();
        finish();
    }

    @Override
    public void permissionsWereDenied() {
        mrzScannerListener.permissionsWereDenied();
        finish();
    }

    //    private static Bitmap loadImageFromStorage(String path) {
//        Bitmap b = null;
//        try {
//            File f = new File(path, OVERLAY_IMG_NAME);
//            b = BitmapFactory.decodeStream(new FileInputStream(f));
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        }
//        return b;
//    }
//
    @Override
    public void onBackPressed() {
        super.onBackPressed();
        if (mrzScannerDismissed != null)
            mrzScannerDismissed.scannerWasDismissed();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        scannerActivityListener = null;
        mrzScanner = null;
    }

    //    private static String saveToInternalStorage(String base64String, Context context) {
//        Bitmap bitmap = RNMrzscannerlibModule.decodeBase64(base64String);
//
//        File directory = context.getDir("imageDir", Context.MODE_PRIVATE);
//        // Create imageDir
//        File mypath = new File(directory, ScannerActivity.OVERLAY_IMG_NAME);
//
//        FileOutputStream fos = null;
//        try {
//            fos = new FileOutputStream(mypath);
//            // Use the compress method on the BitMap object to write image to the OutputStream
//            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
//        } catch (Exception e) {
//            e.printStackTrace();
//        } finally {
//            try {
//                fos.close();
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        }
//        return directory.getAbsolutePath();
//    }

    static void setIdActive(Boolean active) {
        MRZScanner.setIDActive(active);
    }

    static void setPassportActive(Boolean active) {
        MRZScanner.setIDActive(active);
    }

    static void setVisaActive(Boolean active) {
        MRZScanner.setIDActive(active);
    }

    private static Point getDisplaySize(Context context) {
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        final Point size = new Point();
        display.getSize(size);
        return size;
    }

    static void setContinuousScanningEnabled(Boolean enabled) {
        continuousScanningEnabled = enabled;

        if (scannerActivityListener != null) {
            scannerActivityListener.setContinuousScanningEnabled(enabled);
        }
    }

    static void setIgnoreDuplicatesEnabled(Boolean enabled) {
        ignoreDuplicatesEnabled = enabled;

        if (scannerActivityListener != null) {
            scannerActivityListener.setIgnoreDuplicatesEnabled(enabled);
        }
    }

}