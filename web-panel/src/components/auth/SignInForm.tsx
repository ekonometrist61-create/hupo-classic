"use client";

import Input from "@/components/form/input/InputField";
import { useRouter } from "@/i18n/navigation";
import { EyeCloseIcon } from "@/icons";
import { createClient } from "@/utils/supabase/client";
import { useState } from "react";

// Veliler ve adminler bu ekrandan Supabase Auth ile giris yapar.
// Rol denetimi veritabaninda da zorunludur (public.profiles.role ve RLS);
// buradaki kontrol yalnizca kullaniciyi dogru panele yonlendirir.
export default function SignInForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const router = useRouter();

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setLoading(true);

    const supabase = createClient();
    const { data, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError) {
      setError(
        authError.message === "Invalid login credentials"
          ? "E-posta veya parola hatalı."
          : authError.message
      );
      setLoading(false);
      return;
    }

    // Rolu okuyup dogru panele yonlendir.
    const { data: profile } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", data.user.id)
      .maybeSingle();

    setLoading(false);
    const hedef =
      profile?.role === "admin" || profile?.role === "ogretmen"
        ? "/yonetim"
        : profile?.role === "ogrenci"
          ? "/ogrenci"
          : "/veli-paneli";
    router.replace(hedef);
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label
          htmlFor="email"
          className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400"
        >
          E-posta <span className="text-error-500">*</span>
        </label>
        <Input
          id="email"
          type="email"
          required
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="ornek@eposta.com"
        />
      </div>

      <div>
        <label
          htmlFor="password"
          className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400"
        >
          Parola <span className="text-error-500">*</span>
        </label>
        <div className="relative">
          <Input
            id="password"
            type={showPassword ? "text" : "password"}
            required
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Parolanız"
          />
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            aria-label={showPassword ? "Parolayı gizle" : "Parolayı göster"}
            className="absolute end-4 top-1/2 z-30 -translate-y-1/2 cursor-pointer"
          >
            <EyeCloseIcon className="fill-gray-500 dark:fill-gray-400" />
          </button>
        </div>
      </div>

      {error && (
        <p role="alert" className="text-sm text-error-500">
          {error}
        </p>
      )}

      <button
        type="submit"
        disabled={loading}
        className="flex w-full items-center justify-center rounded-lg border border-transparent bg-brand-500 px-6 py-3 text-sm font-medium text-white shadow-theme-xs transition-colors hover:bg-brand-600 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {loading ? "Giriş yapılıyor..." : "Giriş Yap"}
      </button>
    </form>
  );
}
