package org.example.internal;

import org.example.guice.Logger;
import org.example.guice.modules.CustomModuleWithSingletonLogger;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Provider;

public class TestApplication2 {

	public void run() {
		Injector injector = Guice.createInjector(new CustomModuleWithSingletonLogger());
		System.out.println(injector.getInstance(Logger.class));
		System.out.println(injector.getInstance(Logger.class));
		Provider<Logger> provider = injector.getProvider(Logger.class);
		System.out.println(provider.get());
		System.out.println(provider.get());
	}

}
