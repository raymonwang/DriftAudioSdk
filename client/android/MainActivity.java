package com.example.driftaudiosdk;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

import com.lw.RecordImage.GameAvatar;
import com.lw.RecordImage.UrlFileHelper;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

public class MainActivity extends Activity {
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		GameAvatar.GetIntance(MainActivity.this);
		
		Button button = (Button)findViewById(R.id.select_pic_button);
		button.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				GameAvatar.GetIntance(MainActivity.this).setAvaterWithUid(1, 1);
			}
		});
	}

    
    
    


    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        switch (requestCode) {
            
            case 2: // 相册
            	GameAvatar.GetIntance(MainActivity.this).takePictureFromAlbumsResult(data);
                break;
            case 3:
            	GameAvatar.GetIntance(MainActivity.this).zoomPicureResult(data);
                break;
        }
    }

    


    
    
}
