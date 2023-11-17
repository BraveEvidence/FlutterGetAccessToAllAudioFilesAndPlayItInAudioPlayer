package com.example.flutapp

import android.content.ContentUris
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private lateinit var methodChannelResult: MethodChannel.Result
    private val audioList = ArrayList<String>()

    //Old way
    private val requestPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) {
                getAllAudios()
            } else {
                Toast.makeText(this, "Give permission", Toast.LENGTH_LONG).show()
            }
        }

    //New way
    private var resultLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->

            if (hasManageExternalStoragePermission()) {
                getAllAudios()
            } else {
                Toast.makeText(this, "New Give permission", Toast.LENGTH_LONG).show()
            }
        }

    private fun requestManageExternalStoragePermission() {
        if (!hasManageExternalStoragePermission()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                resultLauncher.launch(intent)
            } else {
                //Below Android R
                requestPermissionLauncher.launch(android.Manifest.permission.READ_EXTERNAL_STORAGE)
            }

        }
    }

    private fun hasManageExternalStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            return false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "myImageView",
                MyImageViewFactory()
            )

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("myAudioView", MyAudioViewFactory(this))

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "audioPickerPlatform"
        ).setMethodCallHandler { call, result ->
            methodChannelResult = result
            when (call.method) {
                "pickAudio" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        if (hasManageExternalStoragePermission()) {
                            getAllAudios()
                        } else {
                            requestManageExternalStoragePermission()
                        }
                    } else {
                        requestPermissionLauncher.launch(android.Manifest.permission.READ_EXTERNAL_STORAGE)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getAllAudios() {
        audioList.clear()

        // Define the columns you want to retrieve
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DATA,      // File path
            MediaStore.Audio.Media.TITLE,     // Audio file title
            MediaStore.Audio.Media.ARTIST,    // Artist
            MediaStore.Audio.Media.ALBUM,     // Album
            MediaStore.Audio.Media.DURATION   // Duration
        )

        val audioUri: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI

        // Perform the query
        val cursor = contentResolver.query(audioUri, projection, null, null, null)

        cursor?.use {
            while (it.moveToNext()) {
                val idIndex = cursor.getColumnIndex(MediaStore.Audio.Media._ID)
                val filePathIndex = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)
                val titleIndex = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE)
                val artistIndex = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST)
                val albumIndex = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM)
                val durationIndex = cursor.getColumnIndex(MediaStore.Audio.Media.DURATION)

                if (idIndex >= 0 && filePathIndex >= 0 && titleIndex >= 0 && artistIndex >= 0
                    && albumIndex >= 0 && durationIndex >= 0
                ) {
                    val id = cursor.getLong(idIndex)
                    val filePath = cursor.getString(filePathIndex)
                    val title = cursor.getString(titleIndex)
                    val artist = cursor.getString(artistIndex)
                    val album = cursor.getString(albumIndex)
                    val duration = cursor.getLong(durationIndex)


                    val contentUri: Uri = ContentUris.withAppendedId(audioUri, id)


                    audioList.add("${"content://media/external/audio/media/$id/albumart"}@@$contentUri@@$title")

                }

            }
        }

        methodChannelResult.success(audioList.toString())
    }

}
