// auth.jsx — Tweakd
// Login + Sign-up screens. Same warm-neutral system as the rest of the app:
// warm-white surfaces, near-black ink, orange reserved for the primary CTA + accents.
// Space Grotesk (display) / Manrope (body).

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Brand wordmark + mark
// ─────────────────────────────────────────────────────────
function Brandmark() {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 14 }}>
      <div style={{
        width: 52, height: 52, borderRadius: 16, background: KE.ink,
        display: "grid", placeItems: "center", position: "relative",
        boxShadow: "0 8px 22px rgba(10,10,10,0.16)",
      }}>
        {/* simple spark/tune glyph — geometric only */}
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
          <path d="M13 2L4 13h6l-1 9 9-12h-6l1-8z" fill={KE.accent}/>
        </svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 30,
        letterSpacing: -1.0, color: KE.ink, lineHeight: 1,
      }}>
        Tweakd<span style={{ color: KE.accent }}>.</span>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Form primitives
// ─────────────────────────────────────────────────────────
function FieldLabel({ children }) {
  return (
    <div style={{
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
      letterSpacing: 1.4, color: KE.ink, marginBottom: 8,
    }}>{children}</div>
  );
}

function Field({ label, type = "text", placeholder, value, onChange, prefix, trailing }) {
  const [focused, setFocused] = React.useState(false);
  return (
    <div>
      <FieldLabel>{label}</FieldLabel>
      <div style={{
        height: 52, borderRadius: 12, background: KE.surface,
        border: `1px solid ${focused ? KE.ink : KE.line}`,
        transition: "border-color 160ms ease",
        display: "flex", alignItems: "center", gap: 10, padding: "0 14px",
      }}>
        {prefix && <div style={{ flexShrink: 0, display: "grid", placeItems: "center" }}>{prefix}</div>}
        <input
          type={type}
          value={value}
          onChange={onChange}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          placeholder={placeholder}
          style={{
            flex: 1, minWidth: 0, border: "none", outline: "none", background: "transparent",
            fontFamily: FONT_BODY, fontSize: 15, color: KE.ink, padding: 0,
          }}
        />
        {trailing}
      </div>
    </div>
  );
}

function AtPrefix() {
  return (
    <span style={{
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: KE.mute,
    }}>@</span>
  );
}

function PasswordToggle({ shown, onToggle }) {
  return (
    <button onClick={onToggle} type="button" style={{
      border: "none", background: "transparent", padding: 2, cursor: "pointer",
      display: "grid", placeItems: "center", flexShrink: 0,
    }}>
      {shown ? (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z" stroke={KE.mute} strokeWidth="2" strokeLinejoin="round"/>
          <circle cx="12" cy="12" r="3" stroke={KE.mute} strokeWidth="2"/>
        </svg>
      ) : (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z" stroke={KE.muteSoft} strokeWidth="2" strokeLinejoin="round"/>
          <circle cx="12" cy="12" r="3" stroke={KE.muteSoft} strokeWidth="2"/>
          <path d="M3 3l18 18" stroke={KE.mute} strokeWidth="2" strokeLinecap="round"/>
        </svg>
      )}
    </button>
  );
}

function PrimaryButton({ label, onClick }) {
  const [press, setPress] = React.useState(false);
  return (
    <button
      onClick={onClick}
      onMouseDown={() => setPress(true)}
      onMouseUp={() => setPress(false)}
      onMouseLeave={() => setPress(false)}
      style={{
        width: "100%", height: 56, borderRadius: 14, border: "none",
        background: press ? KE.accentHot : KE.accent, color: KE.onAccent,
        display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
        cursor: "pointer", transition: "background 120ms ease",
      }}
    >
      <span style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 1.6,
        whiteSpace: "nowrap",
      }}>{label}</span>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
        <path d="M5 12h14M13 6l6 6-6 6" stroke={KE.onAccent} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    </button>
  );
}

// ─────────────────────────────────────────────────────────
// Divider
// ─────────────────────────────────────────────────────────
function OrDivider({ label }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
      <div style={{ flex: 1, height: 1, background: KE.line }}/>
      <span style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
        letterSpacing: 1.6, color: KE.mute, whiteSpace: "nowrap",
      }}>{label}</span>
      <div style={{ flex: 1, height: 1, background: KE.line }}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Brand marks for social auth
// ─────────────────────────────────────────────────────────
function GoogleMark() {
  return (
    <svg width="22" height="22" viewBox="0 0 48 48">
      <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"/>
      <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"/>
      <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"/>
      <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"/>
    </svg>
  );
}

function AppleMark() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill={KE.ink}>
      <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
    </svg>
  );
}

function FacebookMark() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24">
      <path fill="#1877F2" d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
    </svg>
  );
}

function SocialRow({ order }) {
  const marks = {
    google:   { mark: <GoogleMark/>,   label: "Google" },
    apple:    { mark: <AppleMark/>,     label: "Apple" },
    facebook: { mark: <FacebookMark/>,  label: "Facebook" },
  };
  return (
    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
      {order.map(k => (
        <button key={k} type="button" style={{
          height: 54, borderRadius: 12, background: KE.surface,
          border: `1px solid ${KE.line}`, cursor: "pointer",
          display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 5,
        }}>
          {marks[k].mark}
          <span style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
            letterSpacing: 0.8, color: KE.ink2,
          }}>{marks[k].label}</span>
        </button>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Bottom switch link
// ─────────────────────────────────────────────────────────
function SwitchLink({ prompt, action, onClick }) {
  return (
    <div style={{
      textAlign: "center", fontFamily: FONT_BODY, fontSize: 13.5, color: KE.mute,
    }}>
      {prompt}{" "}
      <span onClick={onClick} style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, color: KE.ink,
        cursor: "pointer", letterSpacing: -0.1,
        borderBottom: `2px solid ${KE.accent}`, paddingBottom: 1,
      }}>{action}</span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Shell — shared scaffold (status spacer + scroll body)
// ─────────────────────────────────────────────────────────
function Shell({ children }) {
  return (
    <div style={{
      width: 390, height: 844, background: KE.bg,
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column", position: "relative",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        {children}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// LOGIN
// ─────────────────────────────────────────────────────────
function LoginScreen({ onSwitch }) {
  const [email, setEmail] = React.useState("");
  const [pw, setPw] = React.useState("");
  const [showPw, setShowPw] = React.useState(false);

  return (
    <Shell>
      <div style={{ padding: "32px 26px 36px", display: "flex", flexDirection: "column" }}>
        <Brandmark/>

        <div style={{ marginTop: 30, textAlign: "center" }}>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 28,
            letterSpacing: -0.8, color: KE.ink,
          }}>Welcome back</div>
          <div style={{
            fontFamily: FONT_BODY, fontSize: 14, color: KE.mute, marginTop: 6,
          }}>Sign in to get back in the garage.</div>
        </div>

        <div style={{ marginTop: 26, display: "flex", flexDirection: "column", gap: 16 }}>
          <Field
            label="EMAIL"
            type="email"
            placeholder="you@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            prefix={
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <rect x="3" y="5" width="18" height="14" rx="3" stroke={KE.mute} strokeWidth="2"/>
                <path d="M4 7l8 6 8-6" stroke={KE.mute} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            }
          />
          <Field
            label="PASSWORD"
            type={showPw ? "text" : "password"}
            placeholder="Enter your password"
            value={pw}
            onChange={(e) => setPw(e.target.value)}
            prefix={
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <rect x="4" y="10" width="16" height="11" rx="3" stroke={KE.mute} strokeWidth="2"/>
                <path d="M8 10V7a4 4 0 018 0v3" stroke={KE.mute} strokeWidth="2"/>
              </svg>
            }
            trailing={<PasswordToggle shown={showPw} onToggle={() => setShowPw(!showPw)}/>}
          />
        </div>

        <div style={{ marginTop: 12, display: "flex", justifyContent: "flex-end" }}>
          <span style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
            letterSpacing: 0.6, color: KE.ink2, cursor: "pointer",
          }}>FORGOT PASSWORD?</span>
        </div>

        <div style={{ marginTop: 22 }}>
          <PrimaryButton label="SIGN IN"/>
        </div>

        <div style={{ marginTop: 24 }}>
          <OrDivider label="OR CONTINUE WITH"/>
        </div>

        <div style={{ marginTop: 18 }}>
          <SocialRow order={["google", "apple", "facebook"]}/>
        </div>

        <div style={{ marginTop: 28 }}>
          <SwitchLink prompt="New to Tweakd?" action="Create account" onClick={onSwitch}/>
        </div>
      </div>
    </Shell>
  );
}

// ─────────────────────────────────────────────────────────
// SIGN UP
// ─────────────────────────────────────────────────────────
function SignupScreen({ onSwitch }) {
  const [email, setEmail] = React.useState("");
  const [username, setUsername] = React.useState("");
  const [pw, setPw] = React.useState("");
  const [showPw, setShowPw] = React.useState(false);

  return (
    <Shell>
      <div style={{ padding: "32px 26px 36px", display: "flex", flexDirection: "column" }}>
        <Brandmark/>

        <div style={{ marginTop: 30, textAlign: "center" }}>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 28,
            letterSpacing: -0.8, color: KE.ink,
          }}>Join the grid</div>
          <div style={{
            fontFamily: FONT_BODY, fontSize: 14, color: KE.mute, marginTop: 6,
          }}>Create your account and build your garage.</div>
        </div>

        <div style={{ marginTop: 26, display: "flex", flexDirection: "column", gap: 16 }}>
          <Field
            label="EMAIL"
            type="email"
            placeholder="you@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            prefix={
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <rect x="3" y="5" width="18" height="14" rx="3" stroke={KE.mute} strokeWidth="2"/>
                <path d="M4 7l8 6 8-6" stroke={KE.mute} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            }
          />
          <Field
            label="USERNAME"
            placeholder="username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            prefix={<AtPrefix/>}
          />
          <Field
            label="PASSWORD"
            type={showPw ? "text" : "password"}
            placeholder="Create a password"
            value={pw}
            onChange={(e) => setPw(e.target.value)}
            prefix={
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <rect x="4" y="10" width="16" height="11" rx="3" stroke={KE.mute} strokeWidth="2"/>
                <path d="M8 10V7a4 4 0 018 0v3" stroke={KE.mute} strokeWidth="2"/>
              </svg>
            }
            trailing={<PasswordToggle shown={showPw} onToggle={() => setShowPw(!showPw)}/>}
          />
        </div>

        <div style={{ marginTop: 22 }}>
          <PrimaryButton label="CREATE ACCOUNT"/>
        </div>

        <div style={{
          marginTop: 14, textAlign: "center",
          fontFamily: FONT_BODY, fontSize: 11.5, color: KE.mute, lineHeight: 1.55,
        }}>
          By creating an account you agree to the{" "}
          <span style={{ color: KE.ink2, fontWeight: 600 }}>Terms</span> &amp;{" "}
          <span style={{ color: KE.ink2, fontWeight: 600 }}>Privacy Policy</span>.
        </div>

        <div style={{ marginTop: 22 }}>
          <OrDivider label="OR SIGN UP WITH"/>
        </div>

        <div style={{ marginTop: 18 }}>
          <SocialRow order={["google", "facebook", "apple"]}/>
        </div>

        <div style={{ marginTop: 26 }}>
          <SwitchLink prompt="Already have an account?" action="Sign in" onClick={onSwitch}/>
        </div>
      </div>
    </Shell>
  );
}

window.LoginScreen = LoginScreen;
window.SignupScreen = SignupScreen;
window.KE = KE;
