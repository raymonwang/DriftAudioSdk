package com.lw.RecordImage;
/**
 * 7/10/14  11:00 AM
 * Created by yibin.
 */
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

import org.apache.http.util.EncodingUtils;

import android.util.Base64;
import android.util.Log;

public class UrlFileHelper 
{

	 
	 private String multipart_form_data = "multipart/form-data";
	 private String twoHyphens = "--";
	 private String boundary = "------------------------------64b23e4066ed";
	 private String lineEnd = "\r\n";
	
	 private void addFormField(Map<String,String> params, DataOutputStream output) {   
	        StringBuilder sb = new StringBuilder();   
	        for(Map.Entry entry: params.entrySet()) 
	        {   
	            sb.append(twoHyphens + boundary + lineEnd);   
	            sb.append("Content-Disposition: form-data; name=\"" + entry.getKey() + "\"" + lineEnd);   
	            sb.append(lineEnd);   
	            sb.append(entry.getValue() + lineEnd);
	        }   
	        try {   
	            output.writeBytes(sb.toString());// 鍙戦�琛ㄥ崟瀛楁鏁版嵁    
	        } catch (IOException e) {   
	            throw new RuntimeException(e);
	        }   
	    }

	    public String post(String actionUrl, Map<String,String> params,String filename) {
	        HttpURLConnection conn = null;
	        DataOutputStream dataOutputStream = null;
	        BufferedReader input = null;
	        try {
	            URL url = new URL(actionUrl);
	            conn = (HttpURLConnection) url.openConnection();
	            conn.setConnectTimeout(60*1000);
	            conn.setDoInput(true);		
	            conn.setDoOutput(true);		
	            conn.setUseCaches(false);
	            conn.setRequestMethod("POST");
	            conn.setRequestProperty("Connection", "keep-alive");
	            conn.setRequestProperty("Content-Type", multipart_form_data + "; boundary=" + boundary);
	            conn.connect();
	            dataOutputStream = new DataOutputStream(conn.getOutputStream());

	            
	            
	            StringBuilder split = new StringBuilder();
	            split.append(twoHyphens + boundary + lineEnd);
	            split.append("Content-Disposition: form-data; name=\"file\"; filename=\"" + filename + "\"" + lineEnd);
	            split.append("Content-Type: " + "aapplication/octet-stream" + lineEnd);
	            split.append(lineEnd);
	            dataOutputStream.writeBytes(split.toString());    
	            
	            Log.d("uploadvoice", "file = " + filename);
	            FileInputStream fin = new FileInputStream(filename); 
	            int length = fin.available();
	            byte[] buffer = new byte[length];
	            fin.read(buffer);
	            EncodingUtils.getString(buffer, "UTF-8");   
	            fin.close();
	            
	            try {
	                  
	            	dataOutputStream.write(buffer, 0, length);
	            	dataOutputStream.writeBytes(lineEnd);
	            } catch (IOException e) {
	                e.printStackTrace();
	            }
	            
	            if(params != null)
	            	addFormField(params,dataOutputStream);

	            dataOutputStream.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);
	            dataOutputStream.flush();
	           

	            int code = conn.getResponseCode();
	            if(code != 200) {
	                throw new RuntimeException("upload" + actionUrl +"fail");
	            }

	            input = new BufferedReader(new InputStreamReader(conn.getInputStream()));
	            StringBuilder response = new StringBuilder();
	            String oneLine;
	            while((oneLine = input.readLine()) != null) {
	                response.append(oneLine);
	            }
				dataOutputStream.close();
				
//				byte[] base64url = Base64.decode(response.toString(),Base64.DEFAULT);
//				String base64string = new String(base64url);
	            return response.toString();
	            
	        } catch (IOException e) {
	            e.printStackTrace();
	        } finally {
	            
	            try {
	                if(dataOutputStream != null) {
	                    dataOutputStream.close();
	                }
	                if(input != null) {
	                    input.close();
	                }
	            } catch (IOException e) {
	            	 e.printStackTrace();
	            }

	            if(conn != null) {
	                conn.disconnect();
	            }
	        }
			return null;
	    }
	 
	 
	    public boolean getUrlFile(String fileurl,String filepath)
	    {
	    	File file = new File(filepath);
	    	URL voiceUrl;
	        HttpURLConnection conn;
			try {
				
				voiceUrl = new URL(fileurl);
				conn = (HttpURLConnection) voiceUrl.openConnection();
			    conn.setConnectTimeout(30000);
			        conn.setReadTimeout(30000);
			        conn.setInstanceFollowRedirects(true);
			        InputStream is = conn.getInputStream();
			        OutputStream os = new FileOutputStream(file);
			        CopyStream(is, os);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return false;
			}
	   
	        
	    	return true;
	    }
	    
	    public static void CopyStream(InputStream is, OutputStream os) {
	        final int buffer_size = 1024;
	        try {
	            byte[] bytes = new byte[buffer_size];
	            for (; ; ) {
	                int count = is.read(bytes, 0, buffer_size);
	                if (count == -1)
	                    break;
	                os.write(bytes, 0, count);
	            }
	            os.flush();
	            is.close();
	            os.close();
	        } catch (Exception ex) {
	        }
	    }
 
	     
}
