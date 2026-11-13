package com.randyscustomapps.strikeout;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.PendingPurchasesParams;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.QueryPurchasesParams;

import java.util.List;

/**
 * Play refunds a subscription that is still unacknowledged after three days.
 * The Digital Goods API no longer has an acknowledge method, and Strikeout
 * Harvest has no server. This wrapper acknowledges the Play subscription
 * on the device. It does not record the purchase token anywhere.
 */
public final class PlaySubscriptionAck implements Application.ActivityLifecycleCallbacks {
    private static final String TAG = "PlaySubscriptionAck";
    private static BillingClient client;
    private static boolean connecting;

    private PlaySubscriptionAck() {}

    public static void start(Context context) {
        Context appContext = context.getApplicationContext();
        if (!(appContext instanceof Application)) return;
        Application app = (Application) appContext;
        if (client == null) {
            app.registerActivityLifecycleCallbacks(new PlaySubscriptionAck());
            client = BillingClient.newBuilder(app)
                    .enablePendingPurchases(PendingPurchasesParams.newBuilder()
                            .enableOneTimeProducts()
                            .build())
                    .setListener((billingResult, purchases) -> acknowledgeAll(purchases))
                    .build();
        }
        connectAndQuery();
    }

    @Override public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}
    @Override public void onActivityStarted(Activity activity) {}
    @Override public void onActivityResumed(Activity activity) {}
    @Override public void onActivityPaused(Activity activity) {}
    @Override public void onActivityStopped(Activity activity) {}
    @Override public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

    @Override
    public void onActivityDestroyed(Activity activity) {
        if (activity.getClass().getName().endsWith("PaymentActivity")) connectAndQuery();
    }

    private static void connectAndQuery() {
        if (client == null) return;
        if (client.isReady()) {
            query();
            return;
        }
        if (connecting) return;
        connecting = true;
        client.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(BillingResult result) {
                connecting = false;
                if (result.getResponseCode() == BillingClient.BillingResponseCode.OK) query();
            }

            @Override
            public void onBillingServiceDisconnected() {
                connecting = false;
            }
        });
    }

    private static void query() {
        if (client == null || !client.isReady()) return;
        client.queryPurchasesAsync(
                QueryPurchasesParams.newBuilder()
                        .setProductType(BillingClient.ProductType.SUBS)
                        .build(),
                (billingResult, purchases) -> {
                    if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
                        Log.w(TAG, "queryPurchases " + billingResult.getResponseCode());
                        return;
                    }
                    acknowledgeAll(purchases);
                });
    }

    private static void acknowledgeAll(List<Purchase> purchases) {
        if (client == null || purchases == null) return;
        for (Purchase purchase : purchases) {
            if (purchase.getPurchaseState() != Purchase.PurchaseState.PURCHASED) continue;
            if (purchase.isAcknowledged()) continue;
            client.acknowledgePurchase(
                    AcknowledgePurchaseParams.newBuilder()
                            .setPurchaseToken(purchase.getPurchaseToken())
                            .build(),
                    result -> Log.i(TAG, "acknowledge " + result.getResponseCode()));
        }
    }
}
