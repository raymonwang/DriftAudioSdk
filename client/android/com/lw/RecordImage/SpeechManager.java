package com.lw.RecordImage;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.ui.RecognizerDialog;
import com.lw.util.FucUtil;
import com.lw.util.JsonParser;
import com.lw.util.LogUtils;
 

/**
 * 录音解析
 * @author libin
 *
 */
public class SpeechManager {
	//语音转文字
	private int SPEEK_TO_TEXT=10;
	//语音文件转文字
	private int SPEEK_File_TO_TEXT=12;
		
	private int type=0;
	public void setType(int type) {
		this.type = type;
	}

	
	
	private Context context;
	private static String TAG = SpeechManager.class.getSimpleName();
	// 语音听写对象
	private SpeechRecognizer mIat;
	// 语音听写UI
//	private RecognizerDialog mIatDialog;
	// 用HashMap存储听写结果
	private HashMap<String, String> mIatResults = new LinkedHashMap<String, String>();
 
//	private SharedPreferences mSharedPreferences;
	// 引擎类型
	private String mEngineType = SpeechConstant.TYPE_CLOUD;
	// 语记安装助手类
//	ApkInstaller mInstaller;
	
	int ret = 0; // 函数调用返回值
	private RecognizerDialog mIatDialog;
	
	
	public void init(Context context) {
		this.context = context;
		// 使用SpeechRecognizer对象，可根据回调消息自定义界面；
		mIat = SpeechRecognizer.createRecognizer(context, mInitListener);
		// 初始化听写Dialog，如果只使用有UI听写功能，无需创建SpeechRecognizer
		// 使用UI听写功能，请根据sdk文件目录下的notice.txt,放置布局文件和图片资源
		
		mIat.setParameter(SpeechConstant.DOMAIN, "iat");
		mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
		mIat.setParameter(SpeechConstant.ACCENT, "mandarin");
		
		LogUtils.init(context);
		LogUtils.i(TAG, "SpeechManager 初始化 ...");
 
	}
	public void recognizeStream(){
		recognizeStream(null);
	}
	public void recognizeStream(String voicePath){
		type = SPEEK_File_TO_TEXT;
		LogUtils.i(TAG, "SpeechManager 开始录音 ...");
		// 设置参数
		setParam();
		if (!TextUtils.isEmpty(voicePath)) {
			// 设置音频来源为外部文件
			mIat.setParameter(SpeechConstant.AUDIO_SOURCE, "-1");
//			mIat.setParameter(SpeechConstant.SAMPLE_RATE, "8000");
			// 也可以像以下这样直接设置音频文件路径识别（要求设置文件在sdcard上的全路径）：
			// mIat.setParameter(SpeechConstant.AUDIO_SOURCE, "-2");
			// mIat.setParameter(SpeechConstant.ASR_SOURCE_PATH, "sdcard/XXX/XXX.pcm");
			ret = mIat.startListening(mRecognizerListener);
			if (ret != ErrorCode.SUCCESS) {
				showTip("识别失败,错误码：" + ret);
			} else {
				byte[] audioData   = FucUtil.toByteArray(voicePath);
				System.out.println("recognizeStream ... 4");
				if (voicePath.length()==0) {
					return ;
				} 
				System.out.println("recognizeStream ... 4"+voicePath);
				if (null != audioData) {
//					showTip(getString(R.string.text_begin_recognizer));
					// 一次（也可以分多次）写入音频文件数据，数据格式必须是采样率为8KHz或16KHz（本地识别只支持16K采样率，云端都支持），位长16bit，单声道的wav或者pcm
					// 写入8KHz采样的音频时，必须先调用setParameter(SpeechConstant.SAMPLE_RATE, "8000")设置正确的采样率
					// 注：当音频过长，静音部分时长超过VAD_EOS将导致静音后面部分不能识别
					mIat.writeAudio(audioData, 0, audioData.length);
					mIat.stopListening();
					System.out.println("stopListening ... 4");
				} else {
					mIat.cancel();
					showTip("读取音频流失败");
				}
			}
		}else {
			LogUtils.i(TAG, "SpeechManager 设置监听 ...");
			ret = mIat.startListening(mRecognizerListener);
		}
		
	}
	public void cancel(){
		mIsRecording = false;
		mIat.cancel();
	}
	
	public void stopListening(){
		mIsRecording = false;
		mIat.stopListening();
	}
	
	public void record(String wavfilepath,final boolean isRecoginzed){
		try {
			LogUtils.i(TAG, "开始录音");
			if (mIatDialog==null) {
				mIatDialog = new RecognizerDialog(context, mInitListener);
			}
			type = SPEEK_TO_TEXT;
			this.isRecoginzed = isRecoginzed;
			setParam();
			// 设置音频保存路径，保存音频格式支持pcm、wav，设置路径为sd卡请注意WRITE_EXTERNAL_STORAGE权限
			// 注：AUDIO_FORMAT参数语记需要更新版本才能生效
			mIat.setParameter(SpeechConstant.AUDIO_FORMAT,"wav");
			mIat.setParameter(SpeechConstant.ASR_AUDIO_PATH,wavfilepath);
			ret = mIat.startListening(mRecognizerListener);
			if (ret != ErrorCode.SUCCESS) {
				showTip("听写失败,错误码：" + ret);
			} else {
				mIsRecording = true;
				LogUtils.i(TAG, "正在录音...");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public boolean mIsRecording=false;
	public boolean isRecoginzed=false;
	/**
	 * 初始化监听器。
	 */
	private InitListener mInitListener = new InitListener() {

		@Override
		public void onInit(int code) {
			LogUtils.d(TAG, "SpeechRecognizer init() code = " + code);
			if (code != ErrorCode.SUCCESS) {
				showTip("初始化失败，错误码：" + code);
			}
		}
	};

 

	/**
	 * 听写监听器。
	 */
	private RecognizerListener mRecognizerListener = new RecognizerListener() {

		@Override
		public void onBeginOfSpeech() {
			// 此回调表示：sdk内部录音机已经准备好了，用户可以开始语音输入
			showTip("开始说话");
		}

		@Override
		public void onError(SpeechError error) {
			// Tips：
			// 错误码：10118(您没有说话)，可能是录音机权限被禁，需要提示用户打开应用的录音权限。
			// 如果使用本地功能（语记）需要提示用户开启语记的录音权限。
			showTip(error.getPlainDescription(true));
		}

		@Override
		public void onEndOfSpeech() {
			// 此回调表示：检测到了语音的尾端点，已经进入识别过程，不再接受语音输入
			showTip("结束说话");
		}

		@Override
		public void onResult(RecognizerResult results, boolean isLast) {
			LogUtils.d(TAG, results.getResultString());
			 
			if (type == SPEEK_File_TO_TEXT) {
				String result = printResult(results);
				LogUtils.d(TAG, isLast+ " 说话内容 up："+result);
				if (isLast) {
					LogUtils.d(TAG, "说话内容 up："+result);
					if (listener!=null) {
						listener.onResult(result);
					}
					LogUtils.d(TAG, "说话内容 end："+result);
				}
			}else if (type == SPEEK_TO_TEXT) {
				Log.d(TAG, "recognizer result：" + results.getResultString());
				String result = printResult(results);
				LogUtils.d(TAG, isLast+ " 说话内容 up："+result);
				if (isLast) {
					LogUtils.d(TAG, "说话内容 up："+result);
					if (listener!=null && isRecoginzed) {
						listener.onResult(result);
					}
					LogUtils.d(TAG, "说话内容 end："+result);
				}
			}
			
		}

		@Override
		public void onVolumeChanged(int volume, byte[] data) {
			showTip("当前正在说话，音量大小：" + volume);
			LogUtils.d(TAG, "返回音频数据："+data.length);
		}

		@Override
		public void onEvent(int eventType, int arg1, int arg2, Bundle obj) {
			// 以下代码用于获取与云端的会话id，当业务出错时将会话id提供给技术支持人员，可用于查询会话日志，定位出错原因
			// 若使用本地能力，会话id为null
			//	if (SpeechEvent.EVENT_SESSION_ID == eventType) {
			//		String sid = obj.getString(SpeechEvent.KEY_EVENT_SESSION_ID);
			//		LogUtils.d(TAG, "session id =" + sid);
			//	}
		}
	};

	private String printResult(RecognizerResult results) {
		String text = JsonParser.parseIatResult(results.getResultString());

		String sn = null;
		// 读取json结果中的sn字段
		try {
			JSONObject resultJson = new JSONObject(results.getResultString());
			sn = resultJson.optString("sn");
		} catch (JSONException e) {
			e.printStackTrace();
		}

		mIatResults.put(sn, text);

		StringBuffer resultBuffer = new StringBuffer();
		for (String key : mIatResults.keySet()) {
			resultBuffer.append(mIatResults.get(key));
		}
		
		return resultBuffer.toString();
	}

 

	public void showTip(final String str) {
		LogUtils.i(TAG, str);
	}

 
	/**
	 * 参数设置
	 * 
	 * @param param
	 * @return
	 */
	public void setParam() {
		mIatResults.clear();
		// 清空参数
		mIat.setParameter(SpeechConstant.PARAMS, null);

		// 设置听写引擎
		mIat.setParameter(SpeechConstant.ENGINE_TYPE, mEngineType);
		// 设置返回结果格式
		mIat.setParameter(SpeechConstant.RESULT_TYPE, "json");

//		String lag = mSharedPreferences.getString("iat_language_preference",
//				"mandarin");
//		if (lag.equals("en_us")) {
//			// 设置语言
//			mIat.setParameter(SpeechConstant.LANGUAGE, "en_us");
//		} else {
			// 设置语言
			mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
			// 设置语言区域
//			mIat.setParameter(SpeechConstant.ACCENT, lag);
//		}

		// 设置语音前端点:静音超时时间，即用户多长时间不说话则当做超时处理
		mIat.setParameter(SpeechConstant.VAD_BOS, "4000");
		
		// 设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
		mIat.setParameter(SpeechConstant.VAD_EOS, "1000");
		
		// 设置标点符号,设置为"0"返回结果无标点,设置为"1"返回结果有标点
		mIat.setParameter(SpeechConstant.ASR_PTT,"1");
		
		// 设置音频保存路径，保存音频格式支持pcm、wav，设置路径为sd卡请注意WRITE_EXTERNAL_STORAGE权限
		// 注：AUDIO_FORMAT参数语记需要更新版本才能生效
		mIat.setParameter(SpeechConstant.AUDIO_FORMAT,"wav");
//		mIat.setParameter(SpeechConstant.ASR_AUDIO_PATH, Environment.getExternalStorageDirectory()+"/msc/iat.wav");
		
		// 设置听写结果是否结果动态修正，为“1”则在听写过程中动态递增地返回结果，否则只在听写结束之后返回最终结果
		// 注：该参数暂时只对在线听写有效
		mIat.setParameter(SpeechConstant.ASR_DWA, "0");
		
		 
 
	}

	public void onDestroy() {
		// 退出时释放连接
		mIat.cancel();
		mIat.destroy();
	}
	
	SpeechListener listener;
	public void setSpeechListener(SpeechListener l)
	{
		this.listener = l;
	}
	public interface SpeechListener{
		public void onResult(String text);
	}
 
 
	
	
	/////////////////////////////////// 分段解析  开始 ///////////////////////////////////////////

    public void startSplitRead(String filepath){
    	try {
    		
    		ret1 = new StringBuffer();
        	ret2 = new StringBuffer();
        	allreult = new StringBuffer();
        	recognizertext = new StringBuffer();
        	byte[] data = readFileFromSDcard(filepath);
        	if (data==null) {
				return;
			}
        	LogUtils.i("tag", filepath+" "+data.length);
            ArrayList<byte[]> buffers = splitBuffer(data, data.length, 1280);
            writeaudio(buffers);
		} catch (Exception e) {
			// TODO: handle exception
		}
    }
   
    private byte[] readFileFromSDcard(String filepath) {
        byte[] buffer = null;
        FileInputStream in = null;
        try {
            in = new FileInputStream(filepath);
            buffer = new byte[in.available()];
            in.read(buffer);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (in != null) {
                    in.close();
                    in = null;
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return buffer;
    }

  
    public ArrayList<byte[]> splitBuffer(byte[] buffer, int length, int spsize) {
        ArrayList<byte[]> array = new ArrayList<byte[]>();
        if (spsize <= 0 || length <= 0 || buffer == null
                || buffer.length < length)
            return array;
        int size = 0;
        while (size < length) {
            int left = length - size;
            if (spsize < left) {
                byte[] sdata = new byte[spsize];
                System.arraycopy(buffer, size, sdata, 0, spsize);
                array.add(sdata);
                size += spsize;
            } else {
                byte[] sdata = new byte[left];
                System.arraycopy(buffer, size, sdata, 0, left);
                array.add(sdata);
                size += left;
            }
        }
        return array;
    }

    public void writeaudio(final ArrayList<byte[]> buffers) {
    	LogUtils.i(TAG, "开启线程进行翻译");
        new Thread(new Runnable() {
            @Override
            public void run() {
            	mIat.setParameter(SpeechConstant.DOMAIN, "iat");
            	mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
            	mIat.setParameter(SpeechConstant.AUDIO_SOURCE, "-1");
                // 设置多个候选结果
            	mIat.setParameter(SpeechConstant.ASR_NBEST, "3");
            	mIat.setParameter(SpeechConstant.ASR_WBEST, "3");

            	mIat.startListening(mRecognizerListener2);
                for (int i = 0; i < buffers.size(); i++) {
                    try {
                    	mIat.writeAudio(buffers.get(i), 0,
                                buffers.get(i).length);
//                        Thread.sleep(40);
                    } catch (Exception e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
                mIat.stopListening();
                LogUtils.i(TAG, "监听停止");
            }

        }).start();
    }

 
    StringBuffer recognizertext = new StringBuffer();
    StringBuffer allreult = new StringBuffer();
    public RecognizerListener mRecognizerListener2 = new RecognizerListener() {
 
        @Override
        public void onResult(RecognizerResult results, boolean arg1) {
            // 正确的结果
            String text = parseIatResult(results.getResultString());
            recognizertext.append(text);
            Log.i("joResult", "text=" + text);
            // 不标准结果
            allreult.append(ret2.toString());

            if (arg1) {
               
                String text1, text2;
                text1 = recognizertext.toString();
                text2 = allreult.toString();
                boolean isequls = text1.regionMatches(true, 0, text2, 0, 0);
                Log.i("joResult", "isequls=" + isequls);
                
                if (listener!=null) {
                	listener.onResult(recognizertext.toString());
				}
                
            }
        }

		@Override
		public void onBeginOfSpeech() {
			
		}

		@Override
		public void onEndOfSpeech() {
			
		}

		@Override
		public void onError(SpeechError arg0) {
			
		}

		@Override
		public void onEvent(int arg0, int arg1, int arg2, Bundle arg3) {
			
		}

		@Override
		public void onVolumeChanged(int arg0, byte[] arg1) {
			
		}

    };
    StringBuffer ret1;
    StringBuffer ret2;
    private String parseIatResult(String json) {
        ret1 = new StringBuffer();
        ret2 = new StringBuffer();
        try {
            JSONTokener tokener = new JSONTokener(json);
            JSONObject joResult = new JSONObject(tokener);
            Log.i("joResult", "joResult:" + joResult.toString());
            JSONArray words = joResult.getJSONArray("ws");
            for (int i = 0; i < words.length(); i++) {
                // 转写结果词，默认使用第一个结果
                JSONArray items = words.getJSONObject(i).getJSONArray("cw");

                JSONObject obj = items.getJSONObject(0);
                ret1.append(obj.getString("w"));
                Log.i("joResult", "items.length():" + items.length());

                switch (items.length()) {

                case 1:
                    JSONObject obj1 = items.getJSONObject(0);
                    ret2.append(obj1.getString("w"));
                    break;

                case 2:
                    JSONObject obj2 = items.getJSONObject(1);
                    ret2.append(obj2.getString("w"));
                    break;
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ret1.toString();
    }
	
	/////////////////////////////////// 分段解析  结束 ///////////////////////////////////////////
	
	
	
	
	
}
