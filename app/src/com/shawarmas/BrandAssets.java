package com.shawarmas;

import java.awt.Image;
import java.net.URI;
import javax.swing.ImageIcon;

final class BrandAssets {
	private static final String BASE_URL = System.getenv().getOrDefault("IMAGE_BASE_URL", "http://localhost:3000").replaceAll("/+$", "");

	private BrandAssets() {}

	static String resolveUrl(String path) {
		if (path == null || path.isBlank()) return "";
		String trimmed = path.trim();
		if (trimmed.matches("(?i)^https?://.*")) return trimmed;
		return BASE_URL + (trimmed.startsWith("/") ? trimmed : "/" + trimmed);
	}

	static Image load(String filename) {
		try {
			return new ImageIcon(URI.create(resolveUrl("/brand/" + filename)).toURL()).getImage();
		} catch (Exception exception) {
			return null;
		}
	}
}
