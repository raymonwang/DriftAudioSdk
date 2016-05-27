package com.lw.RecordImage;

import java.io.IOException;
import java.io.RandomAccessFile;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;

import com.trunkbow.speextest.WaveJoin;

public class AudioTrackManage {
	private AudioTrack track = null;
	private RandomAccessFile raf = null;

	public void audioTrackPlay(String fileName) {
		if (null != track) {
			track.stop();
			track.release();
		}
		if (null != raf) {
			try {
				raf.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		try {
			track = new AudioTrack(AudioManager.STREAM_MUSIC,
					AudioFileFunc.AUDIO_SAMPLE_RATE,
					AudioFormat.CHANNEL_OUT_MONO,
					AudioFormat.ENCODING_PCM_16BIT, WaveJoin.bufferSizeInBytes,
					AudioTrack.MODE_STREAM);
			raf = new RandomAccessFile(
					AudioFileFunc.getFilePathByName(fileName), "r");
			raf.seek(0);
			byte[] decoded = new byte[320];
			int length = 0;
			while ((length = raf.read(decoded)) != -1) {
				track.write(decoded, 0, length);
				float maxVol = AudioTrack.getMaxVolume();
				track.setStereoVolume(maxVol, maxVol);//
				track.play();
			}
		} catch (Exception e) {
		} finally {

		}
	}

}
