package com.lw.RecordImage;

import java.io.IOException;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.util.Log;

public class GameVoicePlayer 
{
	private MediaPlayer mPlayer = null;
	private final String TAG = "GameVoicePlayer";
	
    private GameVoiceManager mVoicemanager;
	    
    public GameVoicePlayer(GameVoiceManager voicemager)
	    {
	    	mVoicemanager = voicemager;
	    }
	
	public void startPlayFile(String filepath)
	{
        if (mPlayer != null) {
            return;
        }
        mPlayer = new MediaPlayer();
        
		try {
            Log.e(TAG, "DATA SOURCE: " + filepath);
            mPlayer.setDataSource(filepath);
            mPlayer.setAudioStreamType(AudioManager.STREAM_RING);
            mPlayer.setVolume(1.0f,1.0f);
            mPlayer.prepare();
            mPlayer.start();
            mPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mp) {
                    mPlayer.release();
                    mPlayer = null;
                    mVoicemanager.OnPlayingingStop();
                }
            });
        } catch (IOException e) {
            Log.e(TAG, e.toString() + "\nprepare() failed");
            mPlayer.release();
            mPlayer = null;
        }
	}
	
	public void stopPlaying()
	{
		 Log.e(TAG, "stopPlaying");
	     if (mPlayer != null) 
	        {
	    	    mPlayer.stop();
	            mPlayer.release();
	            mPlayer = null;
	        }
	}
}
