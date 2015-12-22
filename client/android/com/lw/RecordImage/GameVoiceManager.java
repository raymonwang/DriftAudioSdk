package com.lw.RecordImage;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.os.Environment;
import android.os.StatFs;
import android.text.TextUtils;

import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechUtility;
import com.lw.RecordImage.SpeechManager.SpeechListener;
import com.lw.util.FileUtils;
import com.lw.util.LogUtils;

/**
 * 7/10/14 11:00 AM Created by yibin.
 */
public class GameVoiceManager {
	 
	private static final String URL_FILE_DIR = "stvoice/";
	private static String FileURL = "http://uploadchat.ztgame.com.cn:10000/wangpan.php";
	private static final String TAG = "GameVoiceManager";
	private String cloudfileUrl;
	private Timer recordingTimer;

	private GameVoicePlayer mPlayer;
	
	private SpeechManager speechManager;

	static GameVoiceManager instance;
	private Activity mActivity;
 
	private static boolean ExistSDCard() {
		if (android.os.Environment.getExternalStorageState().equals(
				android.os.Environment.MEDIA_MOUNTED)) {
			return true;
		} else
			return false;
	}


	public long getSDFreeSize() {
		// 取得SD卡文件路径
		File path = Environment.getExternalStorageDirectory();
		StatFs sf = new StatFs(path.getPath());
		// 获取单个数据块的大小(Byte)
		long blockSize = sf.getBlockSize();
		// 空闲的数据块的数量
		long freeBlocks = sf.getAvailableBlocks();
		// 返回SD卡空闲大小
		// return freeBlocks * blockSize; //单位Byte
		// return (freeBlocks * blockSize)/1024; //单位KB
		return (freeBlocks * blockSize) / 1024 / 1024; // 单位MB
	}
	
 

	public GameVoiceManager(Activity activity) {
		mActivity = activity;
		LogUtils.init(activity);
		createFileDirectory();
		mPlayer = new GameVoicePlayer(this);
		speechManager = new SpeechManager();
		 
		 
		speechManager.setSpeechListener(new SpeechListener() {
			@Override
			public void onResult(String text) {
				try {
					JSONObject jsonObject = new JSONObject();
					jsonObject.put("labelid",labelid+"");
					jsonObject.put("content", text);
					jsonObject.put("isok", "true");
					LogUtils.i(TAG, jsonObject.toString());
					OnReceiveVoiceText(true,jsonObject.toString());
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
		LogUtils.i(TAG, "GameVoiceManager init...");
	}

	public String getFileDirectory() {
		// Should create a folder in /scard/|LOG_DIR|
		File file = null;
		if (ExistSDCard()) {
			file = new File(Environment.getExternalStorageDirectory().toString() + "/"
					+ URL_FILE_DIR);
			if (!file.exists()) {
				file.mkdir();
			}
		}else {
			file = mActivity.getCacheDir();
			File dir = new File(file.getAbsoluteFile()+"/"+URL_FILE_DIR);
			if (!dir.exists()) {
				dir.mkdir();
			}
		}
		
		return file.getAbsolutePath()+"/";
	}

	private boolean createFileDirectory() {
		File record_dir = new File(getFileDirectory());
		if (!record_dir.exists()) {
			return record_dir.mkdir();
		}
		return record_dir.isDirectory();
	}

	public boolean StartUploadingFile(final int index) {
		final String voicefile = getFileDirectory() + index + "_" + "temp.mp3";
		final File recordfile = new File(voicefile);
		if (!recordfile.exists())
			return false;

		final long filesize = recordfile.length();

		Thread postthred = new Thread(new Runnable() {

			@Override
			public void run() {
				cloudfileUrl = new UrlFileHelper().post(FileURL, null,
						voicefile);
				if (cloudfileUrl != null) {
					LogUtils.d(TAG, "upload file successs  －－－" + cloudfileUrl);

					// 根据上传url 重命名文件
					String sVoiceindex = recordfile.getName().split("_")[0];
					int voiceindex = Integer.valueOf(sVoiceindex).intValue();
					String hashname = stringToMD5(cloudfileUrl);
					File sycfile = new File(getFileDirectory() + voiceindex
							+ "_" + hashname + ".amr");
					recordfile.renameTo(sycfile);

					final JSONObject result = new JSONObject();
					try {
						result.put("url", cloudfileUrl);
						result.put("duration", String.valueOf(filesize / 1500));
						result.put("filesize", String.valueOf(filesize));
						mActivity.runOnUiThread(new Runnable() {

							@Override
							public void run() {
								// TODO Auto-generated method stub
								RecordingUploadEnd(true, result.toString());
							}
						});

					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

				} else {

					LogUtils.d(TAG, "upload file fail  －－－" + voicefile);
					JSONObject result = new JSONObject();
					try {

						result.put("lableid", String.valueOf(index));
						RecordingUploadEnd(false, result.toString());
					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

				}

			}
		});

		postthred.start();

		return true;
	}
	private File createFile(String path){
		File file = new File(path);
		try {
			if (file.exists()) {
				file.delete();
			}
			file.createNewFile();
		} catch (Exception e) {
			// TODO: handle exception
		}
		return file;
	}
	
	private boolean isRecoginzed;
	/**
	 * 
	 * @param index
	 * @param isRecoginzed 是否翻译， true翻译
	 * @return
	 */
	private String wavfilepath;
	public boolean StartRecording(int index,final boolean isRecoginzed) {
		this.isRecoginzed = isRecoginzed;
		if (speechManager.mIsRecording) {
			return false;
		}
//		if (mRecorder.mIsRecording) {
//			return false;
//		}
		LogUtils.d(TAG, "StartRecording----------------");
//		String rawfilepath = getFileDirectory() + index + "_temp.raw";
//		 createFile(rawfilepath);
		 
		wavfilepath = getFileDirectory() + index +"_"+System.currentTimeMillis() +"_temp_wav.wav";
		createFile(wavfilepath);
		
		mActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				speechManager.record(wavfilepath,isRecoginzed);
			}
		});
		
//		mRecorder.startRecording(voicefile);
//		mRecorder.startRecordAndFile(rawfilepath,wavfilepath);

		// 启动限时Timer
		recordingTimer = new Timer(false);
		TimerTask stoprecordingTask = new TimerTask() {

			@Override
			public void run() {
				recordingTimer = null;
				StopRecording2();
			}
		};

		recordingTimer.schedule(stoprecordingTask, 30 * 1000);
		return true;
	}

	public boolean StopRecording2() {

		if (speechManager.mIsRecording == false) {
			return false;
		}

		LogUtils.e(TAG, "StopRecording----------------");
		if (recordingTimer != null) {
			recordingTimer.cancel();
			recordingTimer = null;
		}

		speechManager.stopListening();
		
//		mRecorder.stopRecordAndFile();
//		mRecorder.stopRecording();
		// 读取上传
//		final String wavfile = mRecorder.getWavFilePath();
		final File recordfile = new File(wavfilepath);
		LogUtils.e(TAG, "StopRecording----1------------"+recordfile.length());

		while (true) {
			if (recordfile!=null && recordfile.length()>0) {
				break;
			}else {
				try {
					Thread.sleep(10);
				} catch (Exception e) {
				}
			}
		}
		
		LogUtils.e(TAG, "StopRecording----2------------"+recordfile.length());
		final File amrFile = createFile(getFileDirectory()+ System.currentTimeMillis()+"_amr.amr");
//		final File rawFile = createFile(getFileDirectory()+ System.currentTimeMillis()+"_temp_raw.raw");
	 
//		RemoveWaveHeader(wavfilepath, rawFile.getAbsolutePath());
		raw2amr(wavfilepath, amrFile.getAbsolutePath());
	 
		if (!amrFile.exists() || amrFile.length()==0)
			return false;

//		deleteFile(rawFile.getAbsolutePath());

		final long filesize = amrFile.length();
//		final long duration = (int) (filesize / 1500);
		// 上传文件开始
	 
		 LogUtils.i(TAG, "upload file size : "+amrFile.length());
		Thread postthred = new Thread(new Runnable() {

			@Override
			public void run() {

				cloudfileUrl = new UrlFileHelper().post(FileURL, null,
						amrFile.getAbsolutePath());
				if (cloudfileUrl != null) {
					LogUtils.d(TAG, "upload file successs  －－－" + cloudfileUrl);
					// 根据上传url 重命名文件
					
					String sVoiceindex = recordfile.getName().split("_")[0];
					int voiceindex = Integer.valueOf(sVoiceindex).intValue();
					String hashname = stringToMD5(cloudfileUrl);
					File sycfile = new File(getFileDirectory() + voiceindex
							+ "_" + hashname + ".amr");
					amrFile.renameTo(sycfile);
					
					File syc2file = new File(getFileDirectory() + voiceindex
							+ "_" + hashname + ".wav");
					recordfile.renameTo(syc2file);
 
					LogUtils.d(TAG, "rename----------------"+sycfile.getAbsolutePath());
					
					final JSONObject result = new JSONObject();
					try {
						result.put("url", cloudfileUrl);
						result.put("duration", String.valueOf(filesize / 1500));
						result.put("filesize", String.valueOf(filesize));
						result.put("labelid", String.valueOf(voiceindex));
 
						
						mActivity.runOnUiThread(new Runnable() {
							@Override
							public void run() {
								RecordingUploadEnd(true, result.toString());
							}
						});
					} catch (JSONException e) {
						e.printStackTrace();
					}

				} else {
					LogUtils.d(TAG, "upload file fail  －－－" + recordfile);
					String sVoiceindex = recordfile.getName().split("_")[0];
					int voiceindex = Integer.valueOf(sVoiceindex).intValue();
					final JSONObject result = new JSONObject();
					try {

						result.put("lableid", String.valueOf(sVoiceindex));
						mActivity.runOnUiThread(new Runnable() {

							@Override
							public void run() {
								// TODO Auto-generated method stub
								RecordingUploadEnd(false, result.toString());
							}
						});

					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}

				isRecoginzed = false;
			}
		});
		
		postthred.start();

		return true;
	}

	private List<File> getFile(File file) {
		File[] fileArray = file.listFiles();
		List<File> mFileList = null;
		for (File f : fileArray) {
			if (f.isFile()) {
				mFileList.add(f);
			} else {
				getFile(f);
			}
		}
		return mFileList;
	}

	// 文件夹中按时间排序最新的文件读取
	static class CompratorByLastModified implements Comparator {
		public int compare(Object o1, Object o2) {
			File file1 = (File) o1;
			File file2 = (File) o2;
			long diff = file1.lastModified() - file2.lastModified();
			if (diff > 0)
				return 1;
			else if (diff == 0)
				return 0;
			else
				return -1;
		}

		public boolean equals(Object obj) {
			return true; // 简单做法
		}
	}

	private void checkfilestorge() {
		final String voicefile_dir = getFileDirectory();
		File voiceDir = new File(voicefile_dir);
		File[] voicefiles = voiceDir.listFiles();

		if (voicefiles.length > 10) {
			Arrays.sort(voicefiles, new CompratorByLastModified());
			for (int i = 0; i < (voicefiles.length - 5); i++) {
				File deletfile = voicefiles[i];
				if (deletfile.getName().compareTo("temp") != 0)
					deletfile.delete();
			}
		}
	}

	/**
	 * 将字符串转成MD5值
	 * 
	 * @param string
	 * @return
	 */
	private String stringToMD5(String string) {
		byte[] hash;

		try {
			hash = MessageDigest.getInstance("MD5").digest(
					string.getBytes("UTF-8"));
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return null;
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return null;
		}

		StringBuilder hex = new StringBuilder(hash.length * 2);
		for (byte b : hash) {
			if ((b & 0xFF) < 0x10)
				hex.append("0");
			hex.append(Integer.toHexString(b & 0xFF));
		}

		return hex.toString();
	}

	public boolean StartPlayVoiceByIndex(int index) {
		StartPlayVoice(index, cloudfileUrl);
		return true;
	}

	public boolean StartPlayVoice(final int index, final String url) {

		String formatefileUrl = stringToMD5(url);
		final String voicefile = getFileDirectory() + index + "_"
				+ formatefileUrl + ".amr";// "test";//
		// 判断文件是否在磁盘，不在去下载
		File recordfile = new File(voicefile);
		if (!recordfile.exists()) {

			Thread downthred = new Thread(new Runnable() {

				@Override
				public void run() {
					// 检查文件保存10个语音文件
					// checkfilestorge();
					boolean downloadret = new UrlFileHelper().getUrlFile(url,
							voicefile);

					if (downloadret) {
						LogUtils.d(TAG, "下载后播放");
						File recordfile = new File(voicefile);
						
						// long filesize = recordfile
						// 下载成功，开始播放
						long filesize = recordfile.length();
						final JSONObject result = new JSONObject();
						try {
							result.put("filesize", String.valueOf(filesize));
							result.put("labelid", String.valueOf(index));
							mActivity.runOnUiThread(new Runnable() {

								@Override
								public void run() {
									// TODO Auto-generated method stub
									RecordingVoiceDownloadEnd(true,
											result.toString());
								}
							});

						} catch (JSONException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						mPlayer.startPlayFile(voicefile);

					} else {

						final JSONObject result = new JSONObject();
						try {
							result.put("filesize", String.valueOf(0));
							result.put("labelid", String.valueOf(index));
							mActivity.runOnUiThread(new Runnable() {

								@Override
								public void run() {
									// TODO Auto-generated method stub
									RecordingVoiceDownloadEnd(false,
											result.toString());
								}
							});

						} catch (JSONException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}

				}
			});

			downthred.start();
		} else {
			// 开始播放
			mPlayer.startPlayFile(voicefile);
//			spx2WavPlay(voicefile, wavfilename, spxrawname);
		}

		return true;
	}

//	private void amr2WavPlay(String spxPath,String wavfilename,String spxrawname){
//		try {
//			File spxFile = new File(spxPath);
//			File wavFile = new File(wavfilename);
//			if (!wavFile.exists()) {
//				wavFile.createNewFile();
//				File spxRawFile = createFile(spxrawname);
//				LogUtils.i(TAG, "spx to  wav start");
//				waveSpeex.spx2wav(spxFile.getAbsolutePath(), spxRawFile.getAbsolutePath(), wavFile.getAbsolutePath());
//				LogUtils.i(TAG, "spx to  wav end");
//				LogUtils.i(TAG, "play wav start");
//				deleteFile(spxRawFile.getAbsolutePath());
//			}
//			LogUtils.i(TAG, "spxPath: "+spxPath);
//			LogUtils.i(TAG, "wavfile: "+wavfilename);
//			LogUtils.i(TAG, "spxrawname: "+spxrawname);
//			mPlayer.startPlayFile(wavFile.getAbsolutePath());
//			
//		} catch (Exception e) {
//			// TODO: handle exception
//		}
//	}
	
	private void deleteFile(String deletePath){
		try {
			boolean isdelete = FileUtils.deleteFile(deletePath);
			if (isdelete) {
				LogUtils.i(TAG, "delete file: "+deletePath);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public boolean StopPlayVoice(String url) {
		mPlayer.stopPlaying();
		return true;
	}

	public boolean CancelRecordingVoice() {

		if (speechManager.mIsRecording == false) {
			return false;
		}

		LogUtils.d(TAG, "CancelRecordingVoice----------------");
		if (recordingTimer != null) {
			recordingTimer.cancel();
			recordingTimer = null;
		}

//		mRecorder.stopRecording();
		speechManager.stopListening();
//		mRecorder.stopRecordAndFile();

		return true;
	}

	public void OnRecordingVolumeChange(double volume) {
		final JSONObject result = new JSONObject();
		try {
			result.put("power", String.valueOf(volume));
			mActivity.runOnUiThread(new Runnable() {

				@Override
				public void run() {
					// TODO Auto-generated method stub
					RecordingVoiceOnVolume(true, result.toString());
				}
			});

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void OnPlayingingStop() {
		final JSONObject result = new JSONObject();
		try {
			result.put("result", "ok");
			mActivity.runOnUiThread(new Runnable() {

				@Override
				public void run() {
					// TODO Auto-generated method stub

					RecordingPlayVoiceOnStop(true, result.toString());
				}
			});

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static GameVoiceManager GetIntance(Activity activity) {
		if (instance == null) {
			instance = new GameVoiceManager(activity);
		}
		LogUtils.i(TAG, "GameVoiceManager instace ...");
		return instance;
	}

	public static void init(String uploadurl) {
		GameVoiceManager.GetIntance(null).FileURL = uploadurl;
		// GameAvatar.GetIntance(null).UploadFileURL = uploadurl;
	}

	public static void startRecordWithIndex(int index,boolean isRecoginzed) {
		LogUtils.i(TAG, "startRecordWithIndex  ...");
		labelid = index;
		GameVoiceManager.GetIntance(null).StartRecording(index,isRecoginzed);
	}
	private  static int labelid ;

	public static void stopRecording() {
		LogUtils.i(TAG, "stopRecording  ...");
		GameVoiceManager.GetIntance(null).StopRecording2();
	}

	public static void reuploadingRecordingWithIndex(int index) {
		LogUtils.i(TAG, "reuploadingRecordingWithIndex  ...");
		GameVoiceManager.GetIntance(null).StartUploadingFile(index);
	}

	public static void startPlayingWithIndex(int index, String urlfile) {
		if (urlfile == null)
			return;
		// byte[] urlbyte = urlfile.getBytes();
		// byte[] url = Base64.decode(urlbyte, Base64.DEFAULT);
		// String surl = new String(url);
		// Log.e("playing", "=====" + surl);
		GameVoiceManager.GetIntance(null).StartPlayVoice(index, urlfile);
	}

	public static void stopPlayingFile() {
		GameVoiceManager.GetIntance(null).StopPlayVoice(null);
	}

	public static void cancelRecordingVoice() {
		GameVoiceManager.GetIntance(null).CancelRecordingVoice();
	}

	public static void SetParams(String url,String appid){
		FileURL = url;
		LogUtils.i(TAG, "SetParams  ..."+"FileURL: "+url+" appid: "+appid+" activity: ");
		System.out.println();
		if (appid!=null) {
			GameVoiceManager.GetIntance(null).setSpeechParams(appid);
		}
	}
	public static void startVoiceToText(){
		LogUtils.i(TAG, "startVoiceToText  ...");
		GameVoiceManager.GetIntance(null).startSpeechVoice();
	}
	
	public static void stopVoiceToText(){
		LogUtils.i(TAG, "stopVoiceToText  ...");
		GameVoiceManager.GetIntance(null).stopSpeechVoice();
	}
	public static void onVoiceDestroy(){
		LogUtils.i(TAG, "onVoiceDestroy  ...");
		GameVoiceManager.GetIntance(null).onSpeechDestroy();
	}
	
	public void setSpeechParams(String appid){
		if (!TextUtils.isEmpty(appid)) {
			LogUtils.i(TAG, "SpeechUtility  createUtility start ...");
			SpeechUtility.createUtility(mActivity, SpeechConstant.APPID + "="
					+ appid);
			LogUtils.i(TAG, "SpeechUtility  createUtility end ...");
		}else {
			SpeechUtility.createUtility(mActivity, SpeechConstant.APPID + "="
					+ Const.VOICE_APP_ID);
		}
		speechManager.init(mActivity);
	}
	
	public void startSpeechVoice(){
		speechManager.recognizeStream("");
	}
	public void stopSpeechVoice(){
		speechManager.stopListening();
	}
	public void onSpeechDestroy(){
		speechManager.onDestroy();
	}
	
	public native void OnReceiveVoiceText(boolean isok, String result);
	
	public native void RecordingUploadEnd(boolean isok, String result);

	public native void RecordingVoiceDownloadBegin(boolean isok, String result);

	public native void RecordingVoiceDownloadEnd(boolean isok, String result);

	public native void RecordingVoiceOnVolume(boolean isok, String result);

	public native void RecordingPlayVoiceOnStop(boolean isok, String result);
	
	
	public static void raw2amr(String inPath, String outPath) {
		try {

			FileInputStream fileInputStream = new FileInputStream(inPath);
			FileOutputStream fileoutputStream = new FileOutputStream(outPath);
			// 获得Class
			Class<?> cls = Class.forName("android.media.AmrInputStream");
			// 通过Class获得所对应对象的方法
			Method[] methods = cls.getMethods();
			// 输出每个方法名
			fileoutputStream.write(header);
			Constructor<?> con = cls.getConstructor(InputStream.class);
			Object obj = con.newInstance(fileInputStream);
			for (Method method : methods) {
				Class<?>[] parameterTypes = method.getParameterTypes();
				if ("read".equals(method.getName())
						&& parameterTypes.length == 3) {
					byte[] buf = new byte[1024];
					int len = 0;
					while ((len = (int) method.invoke(obj, buf, 0, 1024)) > 0) {
						fileoutputStream.write(buf, 0, len);
					}
					
				}
			}
			for (Method method : methods) {
				if ("close".equals(method.getName())){
					method.invoke(obj);
				}
			}
			fileoutputStream.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	 final private static byte[] header = new byte[]{0x23, 0x21, 0x41, 0x4D, 0x52, 0x0A};
	 
	public static void RemoveWaveHeader(String inFileName, String outFileName) {
		RandomAccessFile raf = null;
		FileOutputStream fileOutputStream = null;
		try {
			raf = new RandomAccessFile(inFileName, "r");
			fileOutputStream = new FileOutputStream(outFileName);

			raf.seek(0);
			raf.skipBytes(44);

			byte[] buff = new byte[1024];
			int rc = 0;
			while ((rc = raf.read(buff, 0, 1024)) > 0) {
				fileOutputStream.write(buff, 0, rc);
			}

			fileOutputStream.close();
			raf.close();
		} catch (Exception e) {
			e.printStackTrace();
			LogUtils.i("test", e.toString());
		}
	}
}
