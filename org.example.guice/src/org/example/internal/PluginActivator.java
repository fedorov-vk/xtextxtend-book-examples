package org.example.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

public class PluginActivator implements BundleActivator {

	@Override
	public void start(BundleContext context) throws Exception {
		System.out.println("Guice Example start!");
		new TestApplication().run();
	}

	@Override
	public void stop(BundleContext context) throws Exception {
		System.out.println("Guice Example stop!");
	}

}
