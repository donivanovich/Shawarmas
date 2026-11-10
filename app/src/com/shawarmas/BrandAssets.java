package com.shawarmas;

import java.awt.Image;
import java.net.URL;
import javax.swing.ImageIcon;

final class BrandAssets {
	private static final String BASE_URL = System.getenv().getOrDefault("IMAGE_BASE_URL", "http://localhost:3000").replaceAll("/+$", "");

	private BrandAssets() {}

	static Image load(String filename) {
		try {
			return new ImageIcon(new URL(BASE_URL + "/brand/" + filename)).getImage();
		} catch (Exception exception) {
			return null;
		}
	}
}
