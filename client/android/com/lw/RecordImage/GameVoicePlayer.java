package com.lw.RecordImage;

import java.io.IOException;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.util.Log;

public class GameVoicePlayer {
	private MediaPlayer mPlayer = null;
	private final String TAG = "GameVoicePlayer";

	private GameVoiceManager mVoicemanager;

	public GameVoicePlayer(GameVoiceManager voicemager) {
		mVoicemanager = voicemager;
	}

	public void startPlayFile(String filepath) {
		try {
			if (mPlayer!=null) {
				return;
			}
			mPlayer = new MediaPlayer();
			
			Log.e(TAG, "DATA SOURCE: " + filepath);
			mPlayer.reset();
			mPlayer.setDataSource(filepath);
			mPlayer.setAudioStreamType(AudioManager.STREAM_RING);
			mPlayer.setVolume(1.0f, 1.0f);
			mPlayer.prepare();
			mPlayer.start();
			mPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
				@Override
				public void onCompletion(MediaPlayer mp) {
					releaseRes();
					mVoicemanager.OnPlayingingStop();
				}
			});
		} catch (IOException e) {
			e.printStackTrace();
			Log.e(TAG, e.toString() + "\nprepare() failed");
			releaseRes();
		}
	}

	public synchronized void stopPlaying() {
		Log.e(TAG, "stopPlaying");
		if (mPlayer != null) {
			try {
				mPlayer.reset();
				mPlayer.stop();
				mPlayer.release();
				mPlayer = null;
			} catch (Exception e) {
				mPlayer = null;
				e.printStackTrace();
			}
		}
	}
 
	private void releaseRes(){
		try {
			mPlayer.reset();
			mPlayer.release();
			mPlayer = null;
		} catch (Exception e) {
			mPlayer = null;
			e.printStackTrace();
		}
	}
}
