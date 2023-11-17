package com.example.flutapp

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import coil.load
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import java.io.FileNotFoundException

class MyImageView(
    private val context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
) : PlatformView {
    private val imageView: ImageView = ImageView(context)

    override fun getView(): View {
        return imageView
    }

    override fun dispose() {}

    init {
        imageView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )

        val thumbnailUri = Uri.parse(
            creationParams?.get("imageUrl").toString()
        )
        val thumbnailByteArray = getThumbnail(thumbnailUri)
        val thumbnailBitmap = byteArrayToBitmap(thumbnailByteArray)
        if (thumbnailBitmap == null) {
            imageView.load(R.mipmap.ic_launcher)
        } else {
            imageView.load(thumbnailBitmap)
        }

    }

    private fun getThumbnail(uri: Uri): ByteArray? {
        try {
            val inputStream = context.contentResolver.openInputStream(uri)
            return inputStream?.readBytes()
        } catch (e: FileNotFoundException) {
            // No album art found, handle this case as needed
            e.printStackTrace()
        }
        return null
    }

    private fun byteArrayToBitmap(byteArray: ByteArray?): Bitmap? {
        if (byteArray == null || byteArray.isEmpty()) {
            return null
        }

        return BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
    }
}