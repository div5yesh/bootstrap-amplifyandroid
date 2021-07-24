#!/bin/bash

# Add this alias and run bootstrap <project name>.
# alias bootstrap=~/bootstrap-amplifyandroid/bootstrap.sh

name=$1
package_name="com.example.${name}"

app_build_config="plugins {
    id 'com.android.application'
}

android {
    compileSdkVersion 30
    buildToolsVersion '30.0.2'

    defaultConfig {
        applicationId '${package_name}'
        minSdkVersion 21
        targetSdkVersion 30
        versionCode 1
        versionName '1.0'
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    // Amplify core dependency
    implementation 'com.amplifyframework:core:1.18.0'
    implementation 'com.amplifyframework:aws-auth-cognito:1.18.0'
    implementation 'com.amplifyframework:aws-api:1.18.0'
    implementation 'com.amplifyframework:aws-storage-s3:1.18.0'

    // Support for Java 8 features
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.1.5'

    implementation 'androidx.appcompat:appcompat:1.3.0'
    implementation 'com.google.android.material:material:1.4.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.0.4'
}"

manifest="<?xml version='1.0' encoding='utf-8'?>
<manifest xmlns:android='http://schemas.android.com/apk/res/android'
    package='${package_name}'>
    <application
        android:name='.AmplifyApp'
        android:label='${name}'>
        <activity android:name='.MainActivity'>
            <intent-filter>
                <action android:name='android.intent.action.MAIN' />
                <category android:name='android.intent.category.LAUNCHER' />
            </intent-filter>
        </activity>
    </application>
</manifest>"

main_activity="package ${package_name};

import android.app.Activity;
import android.os.Bundle;
import android.widget.LinearLayout;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        setContentView(layout);
    }
}"

application="package ${package_name};

import android.app.Application;
import android.util.Log;

import com.amplifyframework.AmplifyException;
import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin;
import com.amplifyframework.storage.s3.AWSS3StoragePlugin;
import com.amplifyframework.api.aws.AWSApiPlugin;
import com.amplifyframework.core.Amplify;

public class AmplifyApp extends Application {
    public void onCreate() {
        super.onCreate();

        try {
            // Amplify.addPlugin(new AWSS3StoragePlugin());
            // Amplify.addPlugin(new AWSCognitoAuthPlugin());
            // Amplify.addPlugin(new AWSApiPlugin());
            Amplify.configure(getApplicationContext());
            Log.i(\"MyAmplifyApp\", \"Initialized Amplify\");
        } catch (AmplifyException error) {
            Log.e(\"MyAmplifyApp\", \"Could not initialize Amplify\", error);
        }
    }
}"

gradle init --type java-application --project-name $name --package $package_name --dsl groovy --test-framework junit
cp ~/bootstrap-amplifyandroid/gradle.properties ~/bootstrap-amplifyandroid/local.properties ~/bootstrap-amplifyandroid/build.gradle .
echo "$app_build_config" > ./app/build.gradle
echo "$manifest" > ./app/src/main/AndroidManifest.xml
echo "$main_activity" > ./app/src/main/java/"${package_name//.//}"/MainActivity.java
echo "$application" > ./app/src/main/java/"${package_name//.//}"/AmplifyApp.java

rm -rf ./app/src/test
rm -rf ./app/src/main/resources
rm ./app/src/main/java/"${package_name//.//}"/App.java

./gradlew build

amplify init