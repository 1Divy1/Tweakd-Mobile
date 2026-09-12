// Post Composer flow — screens (uses window.KEFlow + window.KEPost)
const PF = window.KEFlow;
const PP = window.KEPost;
const { T, DISP, BODY, MONO, Field, Input, Textarea } = PF;
const { PostShell, PostProgress, PostHeader, Switch, ToggleRow, TagChip, PCheck, PClose, PArrow } = PP;

// shared label glyphs for visibility
const HeartGlyph = ({ c }) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 20S3 14 3 8.5A4.5 4.5 0 0112 6a4.5 4.5 0 019 2.5C21 14 12 20 12 20z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>;
const CommentGlyph = ({ c }) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M4 5h16v11H9l-5 4z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>;
const ShareGlyph = ({ c }) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M4 12v7h16v-7M12 3v13M7 8l5-5 5 5" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>;

// ─────────────────────────────────────────────────────────────
// STEP 1 · PHOTOS — selected grid, reorder, cover, add tile
// ─────────────────────────────────────────────────────────────
function PhotoTile({ src, cover, index }) {
  return (
    <div style={{ position: "relative", aspectRatio: "1 / 1", borderRadius: 14, overflow: "hidden",
      background: T.bgSoft, boxShadow: T.shadowCard, border: `1px solid ${T.line}` }}>
      <img src={src} style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover" }}/>
      {cover
        ? <div style={{ position: "absolute", left: 7, bottom: 7, padding: "3px 7px", borderRadius: 6, background: T.accent,
            fontFamily: MONO, fontWeight: 700, fontSize: 8, letterSpacing: 0.8, color: "#fff" }}>COVER</div>
        : <div style={{ position: "absolute", left: 7, bottom: 7, width: 18, height: 18, borderRadius: 6, background: "rgba(11,11,12,0.55)",
            backdropFilter: "blur(4px)", display: "grid", placeItems: "center",
            fontFamily: MONO, fontWeight: 700, fontSize: 9, color: "#fff" }}>{index}</div>}
      {/* drag handle */}
      <div style={{ position: "absolute", left: 6, top: 6, width: 22, height: 22, borderRadius: 7, background: "rgba(11,11,12,0.5)",
        backdropFilter: "blur(4px)", display: "grid", placeItems: "center" }}>
        <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><circle cx="8" cy="6" r="1.6" fill="#fff"/><circle cx="16" cy="6" r="1.6" fill="#fff"/><circle cx="8" cy="12" r="1.6" fill="#fff"/><circle cx="16" cy="12" r="1.6" fill="#fff"/><circle cx="8" cy="18" r="1.6" fill="#fff"/><circle cx="16" cy="18" r="1.6" fill="#fff"/></svg>
      </div>
      {/* remove */}
      <div style={{ position: "absolute", top: 6, right: 6, width: 22, height: 22, borderRadius: 8, background: "rgba(11,11,12,0.55)", backdropFilter: "blur(4px)", display: "grid", placeItems: "center" }}>
        <PClose c="#fff" w={11}/>
      </div>
    </div>);
}
function AddPhotoTile() {
  return (
    <div style={{ aspectRatio: "1 / 1", borderRadius: 14, background: T.surface, border: `1.5px dashed ${T.muteSoft}`,
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 7 }}>
      <div style={{ width: 36, height: 36, borderRadius: 11, background: T.bgSoft, display: "grid", placeItems: "center" }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M3 7h3l2-3h8l2 3h3v12H3z" stroke={T.accent} strokeWidth="2" strokeLinejoin="round"/><circle cx="12" cy="13" r="3.4" stroke={T.accent} strokeWidth="2"/></svg>
      </div>
      <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 1, color: T.mute }}>ADD</span>
    </div>);
}
function StepPhotos({ mode = "create" }) {
  const photos = ["assets/car-4.png", "assets/car-3.png", "assets/car-2.png", "assets/car-1.png"];
  return (
    <PostShell step={1} mode={mode} kicker="PHOTOS" title="Pick your shots"
      sub="Drag to reorder — the cover leads your post. Photos only for now."
      primaryLabel="NEXT">
      <Field label="SELECTED" optional={false}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
          {photos.map((s, i) => <PhotoTile key={s} src={s} cover={i === 0} index={i + 1}/>)}
          <AddPhotoTile/>
        </div>
      </Field>
      <div style={{ marginTop: 4, display: "flex", alignItems: "center", justifyContent: "space-between",
        fontFamily: MONO, fontSize: 10.5, letterSpacing: 0.5, color: T.mute }}>
        <span>4 / 10 PHOTOS</span>
        <span style={{ color: T.muteSoft }}>VIDEOS — COMING SOON</span>
      </div>
    </PostShell>);
}

// ─────────────────────────────────────────────────────────────
// STEP 2 · CAPTION — description w/ counter, suggested hashtags
// ─────────────────────────────────────────────────────────────
function StepCaption({ mode = "create" }) {
  const caption = "Golden hour pulls on the G82 never gets old. Fresh coilovers settled in perfectly this week — sitting exactly where I wanted.";
  return (
    <PostShell step={2} mode={mode} kicker="CAPTION" title="Say something" showBack
      sub="Add a description for your post. Mention details, the story, the build."
      primaryLabel="NEXT">
      <Field label="DESCRIPTION">
        <div style={{ position: "relative" }}>
          <div style={{ minHeight: 150, borderRadius: 14, background: T.surface, border: `1.5px solid ${T.accent}`,
            boxShadow: `0 0 0 4px ${T.accentWash}`, padding: "14px 15px 30px", fontFamily: BODY, fontSize: 15, fontWeight: 500,
            lineHeight: 1.55, color: T.ink }}>{caption}<span style={{ display: "inline-block", width: 2, height: 18, background: T.accent, verticalAlign: "-3px", marginLeft: 1 }}/></div>
          <div style={{ position: "absolute", right: 12, bottom: 10, fontFamily: MONO, fontSize: 10, letterSpacing: 0.5, color: T.mute }}>129 / 2200</div>
        </div>
      </Field>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: T.ink, marginBottom: 9 }}>SUGGESTED</div>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
        {["#bmw", "#m4competition", "#g82", "#stance", "#goldenhour", "#kwsuspension"].map(h => (
          <div key={h} style={{ padding: "9px 14px", borderRadius: 99, background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard,
            fontFamily: MONO, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.2, color: T.ink2 }}>{h}</div>
        ))}
      </div>
    </PostShell>);
}

// ─────────────────────────────────────────────────────────────
// STEP 3 · TAGS — tag cars (garage) + people
// ─────────────────────────────────────────────────────────────
function TagSearchField({ placeholder }) {
  return (
    <div style={{ height: 48, borderRadius: 14, background: T.surface, border: `1.5px solid ${T.line}`, boxShadow: T.shadowCard,
      display: "flex", alignItems: "center", padding: "0 14px", gap: 10, marginBottom: 12 }}>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="11" cy="11" r="7" stroke={T.mute} strokeWidth="2"/><path d="M20 20l-4-4" stroke={T.mute} strokeWidth="2" strokeLinecap="round"/></svg>
      <span style={{ flex: 1, fontFamily: BODY, fontSize: 14.5, fontWeight: 500, color: T.muteSoft }}>{placeholder}</span>
    </div>);
}
function StepTags({ mode = "create" }) {
  return (
    <PostShell step={3} mode={mode} kicker="TAGS" title="Tag cars & people" showBack
      sub="Link the cars in this post from any garage, and tag the people in it."
      primaryLabel="NEXT">
      {/* Cars */}
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 11 }}>
        <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: T.ink }}>CARS</span>
        <span style={{ fontFamily: MONO, fontSize: 9.5, color: T.mute, padding: "2px 7px", borderRadius: 6, background: T.bgSoft, border: `1px solid ${T.line2}` }}>2</span>
      </div>
      <TagSearchField placeholder="Search a car in any garage…"/>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 9, marginBottom: 22 }}>
        <TagChip kind="car" label="2024 M4 Comp" sub="@marcus · G82" img="assets/car-4.png"/>
        <TagChip kind="car" label="GR Supra" sub="@elena · A90" img="assets/car-2.png"/>
      </div>
      {/* People */}
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 11 }}>
        <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: T.ink }}>PEOPLE</span>
        <span style={{ fontFamily: MONO, fontSize: 9.5, color: T.mute, padding: "2px 7px", borderRadius: 6, background: T.bgSoft, border: `1px solid ${T.line2}` }}>3</span>
      </div>
      <TagSearchField placeholder="Search people to tag…"/>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 9 }}>
        <TagChip kind="person" label="Elena R." sub="@elena_r" img="assets/av-2.svg"/>
        <TagChip kind="person" label="Marcus T." sub="@marcust" img="assets/av-4.svg"/>
        <TagChip kind="person" label="Dani K." sub="@dani.k" img="assets/av-6.svg"/>
      </div>
    </PostShell>);
}

// ─────────────────────────────────────────────────────────────
// STEP 4 · VISIBILITY — hide counts + relative-date note
// ─────────────────────────────────────────────────────────────
function StepVisibility({ mode = "create" }) {
  return (
    <PostShell step={4} mode={mode} kicker="VISIBILITY" title="Who sees what" showBack
      sub="Hide a counter and others won't see that number — they can still like, comment and share."
      primaryLabel="NEXT">
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: T.ink, marginBottom: 9 }}>VISIBLE COUNTS</div>
      <div style={{ borderRadius: 18, background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard, overflow: "hidden" }}>
        <ToggleRow icon={<HeartGlyph c={T.accent}/>} title="Show like count" sub="Others can see how many likes this post has" on={true}/>
        <ToggleRow icon={<CommentGlyph c={T.mute}/>} title="Show comment count" sub="Hide the number — comments stay open" on={false}/>
        <ToggleRow icon={<ShareGlyph c={T.accent}/>} title="Show share count" sub="Others can see how many times it was shared" on={true} last/>
      </div>
      {/* relative date note */}
      <div style={{ marginTop: 18, display: "flex", gap: 12, alignItems: "flex-start", padding: "14px 15px", borderRadius: 14,
        background: T.accentWash, border: `1px solid ${T.accentSoft}` }}>
        <div style={{ width: 34, height: 34, borderRadius: 10, background: T.surface, border: `1px solid ${T.accentSoft}`, display: "grid", placeItems: "center", flexShrink: 0 }}>
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke={T.accent} strokeWidth="2"/><path d="M12 7v5l3.5 2" stroke={T.accent} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </div>
        <div style={{ fontFamily: BODY, fontSize: 13, lineHeight: 1.5, color: T.ink2 }}>
          <span style={{ fontWeight: 700, color: T.ink }}>Posts show a relative time</span> — “2h ago”, “3 days ago” — never the exact date. This is automatic and always on.
        </div>
      </div>
    </PostShell>);
}

// ─────────────────────────────────────────────────────────────
// STEP 5 · REVIEW — live post preview + publish
// ─────────────────────────────────────────────────────────────
function PreviewActionBtn({ glyph, count, hidden }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 7 }}>
      {glyph}
      {hidden
        ? null
        : <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12.5, color: T.ink2 }}>{count}</span>}
    </div>);
}
function PostPreview() {
  return (
    <div style={{ borderRadius: 20, background: T.surface, border: `1px solid ${T.line}`, boxShadow: "0 6px 20px rgba(11,11,12,0.06)", overflow: "hidden" }}>
      {/* head */}
      <div style={{ display: "flex", alignItems: "center", gap: 11, padding: "13px 14px" }}>
        <div style={{ width: 40, height: 40, borderRadius: 99, overflow: "hidden", background: T.bgSoft }}>
          <img src="assets/avatar.jpg" style={{ width: "100%", height: "100%", objectFit: "cover" }}/>
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 14.5, color: T.ink, letterSpacing: -0.2 }}>You</span>
            <span style={{ width: 5, height: 5, borderRadius: 99, background: T.accent }}/>
          </div>
          <div style={{ fontFamily: MONO, fontSize: 10, color: T.mute, marginTop: 2, letterSpacing: 0.3 }}>JUST NOW</div>
        </div>
        <svg width="20" height="6" viewBox="0 0 22 6"><circle cx="3" cy="3" r="2.4" fill={T.muteSoft}/><circle cx="11" cy="3" r="2.4" fill={T.muteSoft}/><circle cx="19" cy="3" r="2.4" fill={T.muteSoft}/></svg>
      </div>
      {/* image w/ dots */}
      <div style={{ position: "relative", aspectRatio: "4 / 3", background: "#1a1a1a" }}>
        <img src="assets/car-4.png" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover" }}/>
        <div style={{ position: "absolute", top: 10, right: 10, padding: "4px 9px", borderRadius: 8, background: "rgba(11,11,12,0.55)", backdropFilter: "blur(6px)",
          fontFamily: MONO, fontWeight: 700, fontSize: 9.5, letterSpacing: 0.5, color: "#fff" }}>1 / 4</div>
        <div style={{ position: "absolute", bottom: 10, left: 0, right: 0, display: "flex", justifyContent: "center", gap: 5 }}>
          {[0,1,2,3].map(i => <div key={i} style={{ width: i === 0 ? 16 : 5, height: 5, borderRadius: 99, background: i === 0 ? "#fff" : "rgba(255,255,255,0.5)" }}/>)}
        </div>
        {/* tagged badge */}
        <div style={{ position: "absolute", bottom: 10, left: 10, width: 26, height: 26, borderRadius: 9, background: "rgba(11,11,12,0.55)", backdropFilter: "blur(6px)", display: "grid", placeItems: "center" }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><circle cx="9" cy="8" r="3.2" stroke="#fff" strokeWidth="2"/><path d="M4 19c0-3 2.5-5 5-5s5 2 5 5" stroke="#fff" strokeWidth="2" strokeLinecap="round"/><path d="M16 4l4 4-4 4" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </div>
      </div>
      {/* actions */}
      <div style={{ display: "flex", alignItems: "center", gap: 18, padding: "12px 14px 4px" }}>
        <PreviewActionBtn glyph={<HeartGlyph c={T.ink}/>} count="1,284"/>
        <PreviewActionBtn glyph={<CommentGlyph c={T.ink}/>} count="—" hidden/>
        <PreviewActionBtn glyph={<ShareGlyph c={T.ink}/>} count="62"/>
      </div>
      {/* caption */}
      <div style={{ padding: "4px 14px 14px", fontFamily: BODY, fontSize: 13.5, lineHeight: 1.5, color: T.ink2 }}>
        <span style={{ fontWeight: 700, color: T.ink }}>you</span> Golden hour pulls on the G82 never gets old. Fresh coilovers settled in perfectly this week.
        <span style={{ color: T.accent, fontWeight: 600 }}> #bmw #g82 #stance</span>
      </div>
    </div>);
}
function StepReview({ mode = "create" }) {
  return (
    <PostShell step={5} mode={mode} kicker="REVIEW" title="Looking good?" showBack
      sub="This is exactly how your post appears in the feed."
      primaryLabel={mode === "edit" ? "SAVE CHANGES" : "PUBLISH POST"}>
      <PostPreview/>
      {/* summary chips */}
      <div style={{ marginTop: 16, display: "flex", flexWrap: "wrap", gap: 8 }}>
        {["4 PHOTOS", "2 CARS", "3 PEOPLE", "COMMENT COUNT HIDDEN"].map(s => (
          <div key={s} style={{ padding: "7px 11px", borderRadius: 8, background: T.bgSoft, border: `1px solid ${T.line2}`,
            fontFamily: MONO, fontWeight: 700, fontSize: 9.5, letterSpacing: 0.5, color: T.mute }}>{s}</div>
        ))}
      </div>
    </PostShell>);
}

// ─────────────────────────────────────────────────────────────
// MANAGE SHEET — opens from a post's "…" menu (edit / delete)
// ─────────────────────────────────────────────────────────────
function SheetShell({ children, kicker, title }) {
  return (
    <div style={{ width: 390, height: 844, position: "relative", overflow: "hidden", fontFamily: BODY, color: T.ink }}>
      <div style={{ position: "absolute", inset: 0, background: "#2A2724" }}/>
      <div style={{ position: "absolute", inset: 0, background: "rgba(11,11,12,0.5)" }}/>
      <div style={{ position: "absolute", left: 0, right: 0, bottom: 0, top: "auto", background: T.bg, borderRadius: "26px 26px 0 0",
        boxShadow: "0 -16px 50px rgba(0,0,0,0.4)", display: "flex", flexDirection: "column", overflow: "hidden", paddingBottom: 26 }}>
        <div style={{ flexShrink: 0, padding: "12px 0 0" }}>
          <div style={{ width: 44, height: 5, borderRadius: 99, background: T.muteSoft, margin: "0 auto 14px" }}/>
          <div style={{ padding: "0 20px 14px", display: "flex", alignItems: "flex-start", justifyContent: "space-between" }}>
            <div>
              <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 11, letterSpacing: 1, color: T.accent }}>— {kicker}</div>
              <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 24, letterSpacing: -0.8, color: T.ink, marginTop: 6 }}>{title}</div>
            </div>
            <div style={{ width: 36, height: 36, borderRadius: 12, background: T.surface, border: `1px solid ${T.line}`, display: "grid", placeItems: "center", boxShadow: T.shadowCard }}>
              <PClose/>
            </div>
          </div>
          <div style={{ height: 1, background: T.line }}/>
        </div>
        <div style={{ padding: "16px 20px 8px" }}>{children}</div>
      </div>
    </div>);
}
function SheetAction({ icon, title, sub, danger, accent }) {
  const tint = danger ? "#C8341F" : accent ? T.accent : T.ink;
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 13, padding: "14px 14px", borderRadius: 16, background: T.surface,
      border: `1px solid ${danger ? "#F2D5CE" : T.line}`, boxShadow: T.shadowCard, marginBottom: 11 }}>
      <div style={{ width: 40, height: 40, borderRadius: 12, background: danger ? "rgba(200,52,31,0.08)" : T.bgSoft,
        border: `1px solid ${danger ? "#F2D5CE" : T.line}`, display: "grid", placeItems: "center", flexShrink: 0 }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 15, color: tint, letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontFamily: BODY, fontSize: 12, color: T.mute, marginTop: 2 }}>{sub}</div>
      </div>
      <svg width="8" height="14" viewBox="0 0 8 14"><path d="M1 1l6 6-6 6" stroke={T.muteSoft} strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
    </div>);
}
function ManageSheet() {
  return (
    <SheetShell kicker="MANAGE" title="Post options">
      <SheetAction accent title="Edit post" sub="Photos, caption, tags & visibility"
        icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M4 20h4L19 9l-4-4L4 16v4z" stroke={T.accent} strokeWidth="2" strokeLinejoin="round"/><path d="M14 6l4 4" stroke={T.accent} strokeWidth="2"/></svg>}/>
      <SheetAction title="Hide counts" sub="Quickly toggle likes, comments, shares"
        icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z" stroke={T.ink} strokeWidth="2" strokeLinejoin="round"/><circle cx="12" cy="12" r="3" stroke={T.ink} strokeWidth="2"/></svg>}/>
      <SheetAction title="Copy link" sub="Share this post anywhere"
        icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M9 15l6-6M8 13l-2 2a3.5 3.5 0 005 5l2-2M16 11l2-2a3.5 3.5 0 00-5-5l-2 2" stroke={T.ink} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>}/>
      <SheetAction danger title="Delete post" sub="This can't be undone"
        icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 7h14M9 7V5h6v2M7 7l1 12h8l1-12" stroke="#C8341F" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>}/>
    </SheetShell>);
}

// DELETE CONFIRM
function DeleteConfirm() {
  return (
    <div style={{ width: 390, height: 844, position: "relative", overflow: "hidden", fontFamily: BODY, color: T.ink }}>
      <div style={{ position: "absolute", inset: 0, background: "#2A2724" }}/>
      <div style={{ position: "absolute", inset: 0, background: "rgba(11,11,12,0.55)" }}/>
      <div style={{ position: "absolute", left: 20, right: 20, top: "50%", transform: "translateY(-50%)",
        background: T.bg, borderRadius: 26, boxShadow: "0 24px 60px rgba(0,0,0,0.45)", overflow: "hidden", padding: "26px 22px 20px" }}>
        <div style={{ width: 56, height: 56, borderRadius: 18, background: "rgba(200,52,31,0.08)", border: "1px solid #F2D5CE",
          display: "grid", placeItems: "center", margin: "0 auto 16px" }}>
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none"><path d="M5 7h14M9 7V5h6v2M7 7l1 12h8l1-12" stroke="#C8341F" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </div>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 22, letterSpacing: -0.6, color: T.ink, textAlign: "center" }}>Delete this post?</div>
        <div style={{ fontFamily: BODY, fontSize: 14, color: T.mute, lineHeight: 1.5, textAlign: "center", marginTop: 9 }}>
          Your 4 photos, caption and tags will be permanently removed. This can’t be undone.
        </div>
        <button style={{ width: "100%", height: 54, borderRadius: 16, border: "none", background: "#C8341F", color: "#fff", cursor: "pointer",
          fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.4, marginTop: 20, boxShadow: "0 10px 24px rgba(200,52,31,0.28)" }}>DELETE POST</button>
        <button style={{ width: "100%", height: 50, borderRadius: 16, border: `1.5px solid ${T.line}`, background: T.surface, color: T.ink, cursor: "pointer",
          fontFamily: DISP, fontWeight: 700, fontSize: 12.5, letterSpacing: 1.4, marginTop: 10, boxShadow: T.shadowCard }}>KEEP POST</button>
      </div>
    </div>);
}

// EDIT — review screen prefilled, with destructive footer
function EditReview() {
  return (
    <div style={{ width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column",
      fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden" }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <PostHeader step={5} mode="edit"/>
      <PostProgress current={5} mode="edit"/>
      <div style={{ height: 1, background: T.line, margin: "4px 0 0" }}/>
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "20px 18px 22px" }}>
        <div style={{ marginBottom: 18 }}>
          <div style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: 1, color: T.accent }}>05 — REVIEW EDIT</div>
          <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 26, letterSpacing: -0.9, color: T.ink, marginTop: 7 }}>Save your changes</div>
        </div>
        <PostPreview/>
        <button style={{ width: "100%", height: 52, borderRadius: 16, marginTop: 16, background: T.surface, cursor: "pointer",
          border: "1.5px solid #F2D5CE", color: "#C8341F", fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1.4,
          display: "flex", alignItems: "center", justifyContent: "center", gap: 9, boxShadow: T.shadowCard }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M5 7h14M9 7V5h6v2M7 7l1 12h8l1-12" stroke="#C8341F" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          DELETE POST
        </button>
      </div>
      <div style={{ flexShrink: 0, padding: "14px 18px", borderTop: `1px solid ${T.line}`, background: T.bg, display: "flex", gap: 12 }}>
        <button style={{ width: 100, height: 54, borderRadius: 16, border: `1.5px solid ${T.line}`, background: T.surface, color: T.ink, cursor: "pointer",
          fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1.6, display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: T.shadowCard }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M19 12H6M11 6l-6 6 6 6" stroke={T.ink} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>BACK
        </button>
        <button style={{ flex: 1, height: 54, borderRadius: 16, border: "none", background: T.accent, color: "#fff", cursor: "pointer",
          fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.6, display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
          boxShadow: "0 10px 24px rgba(255,77,0,0.30)" }}>
          SAVE CHANGES<PCheck w={15}/>
        </button>
      </div>
    </div>);
}

Object.assign(window, {
  StepPhotos, StepCaption, StepTags, StepVisibility, StepReview,
  ManageSheet, DeleteConfirm, EditReview, PostPreview,
});
