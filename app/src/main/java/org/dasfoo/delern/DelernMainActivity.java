package org.dasfoo.delern;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.google.android.gms.appinvite.AppInvite;
import com.google.android.gms.appinvite.AppInviteInvitation;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.crash.FirebaseCrash;

import org.dasfoo.delern.models.User;
import org.dasfoo.delern.signin.SignInActivity;
import org.dasfoo.delern.util.LogUtil;

import de.hdodenhof.circleimageview.CircleImageView;

/**
 * Main activity of the application, containing decks and menu.
 */
public class DelernMainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener,
        GoogleApiClient.OnConnectionFailedListener {

    private static final int REQUEST_INVITE = 1;
    private static final String TAG = LogUtil.tagFor(DelernMainActivity.class);

    private FirebaseAnalytics mFirebaseAnalytics;
    private GoogleApiClient mGoogleApiClient;
    private Toolbar mToolbar;
    private DelernMainActivityFragment mListFragment;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_delern_main);
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);
        configureToolbar();

        if (!User.isSignedIn()) {
            startSignIn();
            return;
        }

        mListFragment = new DelernMainActivityFragment();
        // Add the fragment to the 'fragment_container' FrameLayout
        getSupportFragmentManager().beginTransaction()
                .add(R.id.fragment_container, mListFragment).commit();

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, mToolbar, R.string.navigation_drawer_open,
                R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
        configureProfileInfo(navigationView);

        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .enableAutoManage(
                        this /* FragmentActivity */,
                        this /* OnConnectionFailedListener */)
                .addApi(Auth.GOOGLE_SIGN_IN_API)
                .addApi(AppInvite.API)
                .build();
    }

    /**
     * Overriding to close the drawer on Back button instead of closing an activity.
     */
    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean onNavigationItemSelected(@NonNull final MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.nav_import) {
            Toast.makeText(this, R.string.not_implemented, Toast.LENGTH_SHORT).show();
        } else if (id == R.id.nav_export) {
            Toast.makeText(this, R.string.not_implemented, Toast.LENGTH_SHORT).show();
        } else if (id == R.id.nav_manage) {
            Toast.makeText(this, R.string.not_implemented, Toast.LENGTH_SHORT).show();
        } else if (id == R.id.nav_share) {
            Toast.makeText(this, R.string.not_implemented, Toast.LENGTH_SHORT).show();
        } else if (id == R.id.nav_send) {
            Toast.makeText(this, R.string.not_implemented, Toast.LENGTH_SHORT).show();
        } else if (id == R.id.nav_invite) {
            sendInvitation();
        } else if (id == R.id.nav_sign_out) {
            // If user signs out, remove all listeners in advance that can be.
            // OnStop called after a sign out. User is already signed out,
            // but listeners are attached yet, therefore log has permission denied message.
            mListFragment.cleanup();
            signOut();
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    private void sendInvitation() {
        Intent intent = new AppInviteInvitation.IntentBuilder(getString(R.string.invitation_title))
                .setMessage(getString(R.string.invitation_message))
                .setCallToActionText(getString(R.string.invitation_cta))
                .build();
        startActivityForResult(intent, REQUEST_INVITE);
    }

    private void signOut() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(R.string.sign_out_warning);
        builder.setPositiveButton(R.string.sign_out, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(final DialogInterface dialog, final int which) {
                FirebaseAuth.getInstance().signOut();
                Auth.GoogleSignInApi.signOut(mGoogleApiClient);
                startSignIn();
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(final DialogInterface dialog, final int which) {
                dialog.cancel();
            }
        });
        builder.show();
    }

    private void configureToolbar() {
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        if (mToolbar != null) {
            setSupportActionBar(mToolbar);
        }
    }

    private void configureProfileInfo(final NavigationView navigationView) {
        View hView = navigationView.getHeaderView(0);
        CircleImageView profilePhoto = (CircleImageView) hView.findViewById(R.id.profile_image);
        TextView userName = (TextView) hView.findViewById(R.id.user_name);
        TextView userEmail = (TextView) hView.findViewById(R.id.user_email);

        FirebaseUser user = User.getCurrentUser();
        if (user != null) {
            userName.setText(user.getDisplayName());
            userEmail.setText(user.getEmail());
            Glide.with(this)
                    .load(user.getPhotoUrl())
                    .into(profilePhoto);
        }
    }

    @Override
    protected void onActivityResult(final int requestCode, final int resultCode,
                                    final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.d(TAG, "onActivityResult: requestCode=" + requestCode + ", resultCode=" + resultCode);

        if (requestCode == REQUEST_INVITE) {
            if (resultCode == RESULT_OK) {
                Bundle payload = new Bundle();
                payload.putString(FirebaseAnalytics.Param.VALUE, "sent");
                mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.SHARE,
                        payload);
            } else {
                Bundle payload = new Bundle();
                payload.putString(FirebaseAnalytics.Param.VALUE, "not sent");
                mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.SHARE,
                        payload);
                Toast.makeText(this, R.string.invitation_failed_message, Toast.LENGTH_SHORT).show();
            }
        }
    }

    /**
     * Notify the user that sign in has permanently failed.
     *
     * @param connectionResult information about unsuccessful connection attempt
     */
    @Override
    public void onConnectionFailed(@NonNull final ConnectionResult connectionResult) {
        // An unresolvable error has occurred and Google APIs (including Sign-In) will not
        // be available.
        Log.d(TAG, "onConnectionFailed:" + connectionResult);
        FirebaseCrash.logcat(Log.ERROR, TAG, connectionResult.getErrorMessage());
        Toast.makeText(this, "Google Play Services error.", Toast.LENGTH_SHORT).show();
    }

    private void startSignIn() {
        // Per https://goo.gl/qHTbjw and https://goo.gl/rnD2g3.
        Intent signInIntent = new Intent(this, SignInActivity.class);
        signInIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(signInIntent);
        finish();
    }
}
