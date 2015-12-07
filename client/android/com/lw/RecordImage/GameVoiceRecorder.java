package com.lw.RecordImage;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.media.MediaRecorder.OnInfoListener;
import android.os.Environment;
import android.text.format.Time;
import android.util.Log;

import java.io.*;
import java.util.Timer;
import java.util.TimerTask;

/**
 * 7/10/14  11:00 AM
 * Created by yibin.
 */
public class GameVoiceRecorder {

    private static final String TAG = "GameAudioRecorder";
    private MediaRecorder mRecorder = null;

    public static final int SAMPLE_RATE = 16000;

    private Mp3Conveter mConveter;
    private short[] mBuffer;
    boolean mIsRecording = false;
    private File mRawFile;
    private File mEncodedFile;
    private String mFilepath;
    private Timer calcVolumeTimer;

    private GameVoiceManager mVoicemanager;
    
    public GameVoiceRecorder(GameVoiceManager voicemager)
    {
    	mVoicemanager = voicemager;
    }
    
  
    /**
     * 开始录音
     */
    
    private void createMediaRecord(String filepath){
        /* ①Initial：实例化MediaRecorder对象 */
    	mRecorder = new MediaRecorder();
        
       /* setAudioSource/setVedioSource*/
    	mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);//设置麦克风
        
       /* 设置输出文件的格式：THREE_GPP/MPEG-4/RAW_AMR/Default
        * THREE_GPP(3gp格式，H263视频/ARM音频编码)、MPEG-4、RAW_AMR(只支持音频且音频编码要求为AMR_NB)
        */
    	mRecorder.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
         
        /* 设置音频文件的编码：AAC/AMR_NB/AMR_MB/Default */
    	mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
        
   }
    
    public void startRecording(String filepath) {

        if(mIsRecording){
            return;
        }

        Log.e(TAG, "startRcording");
        if (mRecorder == null) {
            
        	 createMediaRecord(filepath);
        }
        
        mFilepath = filepath;
     
        try{
        	
        	 /* 设置输出文件的路径 */
        	mEncodedFile = getFile(mFilepath,"amr");
	           if (mEncodedFile.exists()) {  
	           	mEncodedFile.delete();  
	           } 
            mRecorder.setOutputFile(mFilepath + ".amr");
            mRecorder.prepare();
            mRecorder.start();
            // 让录制状态为true  
            mIsRecording = true;
            calculateVolume(true);
            return;
        }catch(IOException ex){
            ex.printStackTrace();
            mRecorder.release();
            mRecorder = null;
            return;
        }
    }
    
    private void calculateVolume(boolean startorstop)
    {
    	if(startorstop)
    	{
	    	
	  	  //启动限时Timer
			 calcVolumeTimer = new Timer(false);
			  TimerTask volumeTask = new TimerTask() {
				
				@Override
				public void run() {
					if(mRecorder != null)
					{
						double volume = 0;
						volume = Math.log10(mRecorder.getMaxAmplitude() / 300)/2.5;
						Log.e("calculateVolume","ratio = " + volume);
						mVoicemanager.OnRecordingVolumeChange(volume);
					}
				}
			  };
			  
			calcVolumeTimer.schedule(volumeTask,500,500);
	    	
    	}else{
    		
    		calcVolumeTimer.cancel();
    		calcVolumeTimer = null;
    	}
    	
    }


    private boolean mIsPause=false;

    public void pauseRecording(){
            mIsPause = true;
    }

    public void restartRecording(){
            mIsPause = false;
    }


    public void stopRecording() {
        Log.e(TAG, "stopRecording");
        if (mRecorder == null) {
            return;
        }
        if(!mIsRecording){
            return;
        }
        calculateVolume(false);
        mRecorder.stop();
        mRecorder.release();
        mRecorder = null;
        mIsPause = false;
        mIsRecording = false;
    }
    
    public String GetMp3FilePath()
    {
    	return mEncodedFile.getAbsolutePath();
    }



    public void release() {
        /*
        Log.e(TAG, "release");
        if (mPlayer != null) {
            mPlayer.stop();
            mPlayer.release();
            mPlayer = null;
        }
        */
        if (mRecorder != null) {
            mRecorder.stop();
            mRecorder.release();
            mIsPause = false;
            mIsRecording = false;
        }

        if(mConveter!=null)
            mConveter.destroyEncoder();
    }

    public File getFile(final String filepath,final String suffix) {
        Time time = new Time();
        time.setToNow();
        File f= new File(filepath + "." + suffix);
        Log.e(TAG,"file address:"+f.getAbsolutePath());
        return f;
    }
}
