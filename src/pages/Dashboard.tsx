import { useEffect, useMemo, useState } from "react";
import { useAuth } from "@/hooks/use-auth";
import { useNavigate } from "react-router";
import { useMutation, useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Checkbox } from "@/components/ui/checkbox";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { toast } from "sonner";
import {
  Search, Plus, Trash2, Copy, Star, Shirt, Layers, Sparkles, Share2, Download, Upload, LogOut, CalendarDays, MapPin, SlidersHorizontal, X, Scan, Shield, HardDrive
} from "lucide-react";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
const CATEGORIES = ["General","Clothing","Shoes","Toiletries","Tech","Documents","Health","Other"] as const;

const STARTER_TEMPLATES = [
  { name: "Weekend City · 2 Nights", tag: "Weekend", desc: "Compact city itinerary", items: [
    { name:"Linen shirt", category:"Clothing", quantity:2, essential:true },
    { name:"Dark trousers", category:"Clothing", quantity:1, essential:true },
    { name:"Sneakers", category:"Shoes", quantity:1, essential:true },
    { name:"Toiletry kit", category:"Toiletries", quantity:1, essential:true },
    { name:"Charger and cable", category:"Tech", quantity:1, essential:true },
    { name:"Passport or ID", category:"Documents", quantity:1, essential:true },
  ]},
  { name: "Business · Three Days", tag: "Work", desc: "Meetings and transit", items: [
    { name:"White shirt", category:"Clothing", quantity:3, essential:true },
    { name:"Blazer", category:"Clothing", quantity:1, essential:false },
    { name:"Dress shoes", category:"Shoes", quantity:1, essential:true },
    { name:"Laptop and charger", category:"Tech", quantity:1, essential:true },
    { name:"Notebook", category:"Documents", quantity:1, essential:false },
  ]},
  { name: "Coastal Week", tag: "Summer", desc: "Light, breathable packing", items: [
    { name:"Swim shorts", category:"Clothing", quantity:2, essential:true },
    { name:"Linen trousers", category:"Clothing", quantity:1, essential:false },
    { name:"Sandals", category:"Shoes", quantity:1, essential:true },
    { name:"Sunscreen", category:"Health", quantity:1, essential:true },
    { name:"Sunglasses", category:"Other", quantity:1, essential:false },
  ]},
];

export default function Dashboard() {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();
  const trips = useQuery(api.packing.listTrips) ?? [];
  const templates = useQuery(api.packing.listTemplates) ?? [];

  const [activeTripId, setActiveTripId] = useState<string | null>(null);
  const activeTrip = useMemo(() => trips.find(t=> String(t._id)===activeTripId) ?? trips[0] ?? null, [trips, activeTripId]);
  useEffect(()=>{ if(!activeTripId && trips[0]) setActiveTripId(String(trips[0]._id)); }, [trips, activeTripId]);

  const items = useQuery(api.packing.listItems, activeTrip ? { tripId: activeTrip._id as any } : "skip") ?? [];
  const outfits = useQuery(api.packing.listOutfits, activeTrip ? { tripId: activeTrip._id as any } : "skip") ?? [];

  const createTrip = useMutation(api.packing.createTrip);
  const deleteTrip = useMutation(api.packing.deleteTrip);
  const duplicateTrip = useMutation(api.packing.duplicateTrip);
  const updateTripStatus = useMutation(api.packing.updateTripStatus);
  const addItem = useMutation(api.packing.addItem);
  const togglePacked = useMutation(api.packing.togglePacked);
  const deleteItem = useMutation(api.packing.deleteItem);
  const updateItem = useMutation(api.packing.updateItem);
  const createTemplate = useMutation(api.packing.createTemplate);
  const applyTemplate = useMutation(api.packing.applyTemplate);
  const deleteTemplate = useMutation(api.packing.deleteTemplate);
  const createOutfit = useMutation(api.packing.createOutfit);
  const deleteOutfit = useMutation(api.packing.deleteOutfit);

  const [tripSearch, setTripSearch] = useState("");
  const [itemSearch, setItemSearch] = useState("");
  const [filterCat, setFilterCat] = useState<string>("all");
  const [filterPacked, setFilterPacked] = useState<"all"|"packed"|"unpacked">("all");
  const [showEssentialOnly, setShowEssentialOnly] = useState(false);
  const [newTripOpen, setNewTripOpen] = useState(false);
  const [newTrip, setNewTrip] = useState({ title:"", destination:"", startDate:"", endDate:"", purpose:"" });
  const [addRow, setAddRow] = useState({ name:"", category:"General", quantity:1, essential:false, notes:"" });
  const [outfitName, setOutfitName] = useState("");
  const [outfitDay, setOutfitDay] = useState("");
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  const filteredTrips = trips.filter(t=>{
    const q = tripSearch.toLowerCase();
    return !q || t.title.toLowerCase().includes(q) || t.destination.toLowerCase().includes(q);
  });

  const grouped = useMemo(()=>{
    let list = [...items];
    if(itemSearch) list = list.filter(i=> i.name.toLowerCase().includes(itemSearch.toLowerCase()) || i.category.toLowerCase().includes(itemSearch.toLowerCase()));
    if(filterCat!=="all") list = list.filter(i=> i.category===filterCat);
    if(filterPacked==="packed") list = list.filter(i=> i.packed);
    if(filterPacked==="unpacked") list = list.filter(i=> !i.packed);
    if(showEssentialOnly) list = list.filter(i=> i.essential);
    const map: Record<string, typeof list> = {};
    for(const it of list){ (map[it.category] ??= []).push(it); }
    return map;
  }, [items, itemSearch, filterCat, filterPacked, showEssentialOnly]);

  const progress = items.length ? Math.round(items.filter(i=>i.packed).length / items.length * 100) : 0;
  const handleSignOut = async()=>{ await signOut(); navigate("/"); };

  const handleCreateTrip = async()=>{
    if(!newTrip.title.trim() || !newTrip.destination.trim()) return toast.error("Please add a title and destination");
    const id = await createTrip({ title: newTrip.title, destination: newTrip.destination, startDate: newTrip.startDate || undefined, endDate: newTrip.endDate || undefined, purpose: newTrip.purpose || undefined });
    setNewTrip({ title:"", destination:"", startDate:"", endDate:"", purpose:"" });
    setNewTripOpen(false);
    setActiveTripId(String(id));
    toast.success("Trip created");
  };

  const seedTemplate = async(idx:number)=>{
    const t = STARTER_TEMPLATES[idx];
    await createTemplate({ name: t.name, description: t.desc, tag: t.tag, items: t.items });
    toast.success(`Template added: ${t.name}`);
  };

  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-20 backdrop-blur-xl bg-background/80 border-b border-border">
        <div className="max-w-[1360px] mx-auto px-4 sm:px-6 h-[56px] flex items-center gap-3">
          <div className="flex items-center gap-2.5">
            <div className="size-8 rounded-[10px] bg-primary text-primary-foreground grid place-items-center"><Scan className="size-4" /></div>
            <span className="text-[15px] font-semibold tracking-[-0.02em]" style={serif}>PackWise</span>
            <span className="hidden lg:inline text-[11px] font-mono uppercase tracking-[0.12em] text-muted-foreground ml-1">Premium · Private · On Device</span>
          </div>
          <div className="hidden sm:flex items-center gap-2 ml-4">
            <Badge variant="secondary" className="rounded-full font-normal">{trips.length} trips</Badge>
            <Badge variant="outline" className="rounded-full font-normal">{items.length} items</Badge>
            <span className="hidden md:inline-flex items-center gap-1.5 text-xs text-muted-foreground ml-1"><Shield className="size-3.5" /> Private workspace</span>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <span className="hidden sm:inline text-sm text-muted-foreground truncate max-w-[18ch]">{user?.email ?? user?.name ?? ""}</span>
            <Button variant="ghost" size="sm" onClick={handleSignOut} className="gap-1.5"><LogOut className="size-3.5" /> Sign out</Button>
          </div>
        </div>
      </header>

      <div className="max-w-[1360px] mx-auto px-4 sm:px-6 py-6 grid lg:grid-cols-[308px_1fr] gap-6 items-start">
        <aside className="lg:sticky lg:top-[68px] space-y-4">
          <Card className="rounded-[20px] p-4 border-border bg-card">
            <div className="flex items-center justify-between">
              <div>
                <div className="font-semibold leading-none" style={serif}>Trips</div>
                <div className="text-[11px] font-mono uppercase tracking-widest text-muted-foreground mt-1">Local library</div>
              </div>
              <Dialog open={newTripOpen} onOpenChange={setNewTripOpen}>
                <DialogTrigger asChild><Button size="sm" className="rounded-full gap-1.5 h-8"><Plus className="size-3.5" /> New trip</Button></DialogTrigger>
                <DialogContent className="rounded-2xl">
                  <DialogHeader><DialogTitle style={serif}>New trip</DialogTitle></DialogHeader>
                  <p className="text-xs text-muted-foreground -mt-2">Stored locally. No account or connection required.</p>
                  <div className="grid gap-3">
                    <Input placeholder="Title — for example, Kyoto in Spring" value={newTrip.title} onChange={e=>setNewTrip({...newTrip, title:e.target.value})} />
                    <Input placeholder="Destination" value={newTrip.destination} onChange={e=>setNewTrip({...newTrip, destination:e.target.value})} />
                    <div className="grid grid-cols-2 gap-3">
                      <Input type="date" value={newTrip.startDate} onChange={e=>setNewTrip({...newTrip, startDate:e.target.value})} />
                      <Input type="date" value={newTrip.endDate} onChange={e=>setNewTrip({...newTrip, endDate:e.target.value})} />
                    </div>
                    <Input placeholder="Purpose — business, leisure, family" value={newTrip.purpose} onChange={e=>setNewTrip({...newTrip, purpose:e.target.value})} />
                    <Button onClick={handleCreateTrip} className="rounded-full">Create trip</Button>
                  </div>
                </DialogContent>
              </Dialog>
            </div>

            <div className="relative mt-3">
              <Search className="size-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
              <Input placeholder="Search trips" value={tripSearch} onChange={e=>setTripSearch(e.target.value)} className="pl-8 h-9 rounded-full bg-secondary/60 border-transparent" />
            </div>

            <div className="mt-3 space-y-2 max-h-[42vh] overflow-auto pr-1">
              {filteredTrips.length===0 && <div className="text-sm text-muted-foreground py-6 text-center border border-dashed rounded-xl">No trips yet. Create your first to begin.</div>}
              {filteredTrips.map(t=>{
                const isActive = activeTrip && String(activeTrip._id)===String(t._id);
                return (
                  <button key={String(t._id)} onClick={()=>setActiveTripId(String(t._id))}
                    className={`w-full text-left rounded-2xl border p-3 transition ${isActive ? "bg-primary text-primary-foreground border-primary" : "bg-white hover:bg-secondary border-border"}`}>
                    <div className="flex items-center gap-2">
                      <span className={`text-[10px] font-mono uppercase tracking-widest px-1.5 py-0.5 rounded-full ${isActive ? "bg-white/15" : "bg-secondary"}`}>{t.status}</span>
                      <span className="ml-auto text-[11px] opacity-70">{t.startDate || "—"}</span>
                    </div>
                    <div className="font-medium leading-tight mt-1.5 line-clamp-1" style={serif}>{t.title}</div>
                    <div className={`text-xs flex items-center gap-1 ${isActive ? "opacity-80" : "text-muted-foreground"}`}><MapPin className="size-3" />{t.destination}</div>
                  </button>
                );
              })}
            </div>
            <div className="mt-3 flex items-center gap-1.5 text-[11px] text-muted-foreground"><HardDrive className="size-3" /> Stored locally on this device</div>
          </Card>

          <Card className="rounded-[20px] p-4">
            <div className="flex items-center gap-2 font-semibold" style={serif}><Sparkles className="size-4" /> Templates</div>
            <p className="text-xs leading-5 text-muted-foreground mt-1">Reusable systems saved on device. Apply with one tap.</p>
            <div className="mt-3 space-y-2">
              {templates.map(t=>(
                <div key={String(t._id)} className="flex items-center gap-2 rounded-xl border p-2.5 bg-white">
                  <div className="min-w-0 flex-1">
                    <div className="text-sm font-medium leading-none truncate">{t.name}</div>
                    <div className="text-xs text-muted-foreground truncate">{t.tag ?? "Custom"}</div>
                  </div>
                  <Button variant="ghost" size="icon" className="size-7" title="Apply to current trip" disabled={!activeTrip} onClick={async()=>{ if(!activeTrip) return; await applyTemplate({ templateId: t._id as any, tripId: activeTrip._id as any }); toast.success("Template applied"); }}><Download className="size-3.5" /></Button>
                  <Button variant="ghost" size="icon" className="size-7" onClick={async()=>{ await deleteTemplate({ templateId: t._id as any }); toast.success("Template removed"); }}><Trash2 className="size-3.5" /></Button>
                </div>
              ))}
              {templates.length===0 && <div className="text-xs text-muted-foreground">No templates yet. Add a starter below or save any trip.</div>}
              <div className="grid grid-cols-1 gap-1.5 pt-1">
                {STARTER_TEMPLATES.map((s,i)=>(
                  <Button key={s.name} variant="outline" size="sm" className="justify-between rounded-full h-8 text-xs" onClick={()=>seedTemplate(i)}><span>{s.name}</span><Plus className="size-3" /></Button>
                ))}
              </div>
              {activeTrip && items.length>0 && (
                <Button variant="secondary" size="sm" className="w-full rounded-full mt-1" onClick={async()=>{
                  await createTemplate({ name: `${activeTrip.title} Template`, description: "Saved from trip", items: items.map(it=>({ name: it.name, category: it.category, quantity: it.quantity, essential: it.essential })) });
                  toast.success("Saved as template");
                }}>Save current trip as template</Button>
              )}
            </div>
          </Card>
        </aside>

        <main className="min-w-0 space-y-4">
          {!activeTrip ? (
            <Card className="rounded-[24px] p-10 text-center border-dashed">
              <div className="size-12 mx-auto rounded-2xl bg-secondary grid place-items-center"><Scan className="size-6" /></div>
              <h2 className="text-[28px] mt-4" style={serif}>Pack with <span className="italic font-light">precision</span></h2>
              <p className="text-sm leading-6 text-muted-foreground mt-2 max-w-[50ch] mx-auto">Create a trip to access your private dashboard, detailed item views, and day-by-day outfit planning. Everything runs locally and remains yours.</p>
              <Button className="rounded-full mt-5" onClick={()=>setNewTripOpen(true)}>Create your first trip</Button>
              <p className="text-[11px] font-mono uppercase tracking-widest text-muted-foreground mt-3">No mandatory login · Works offline · Complete local ownership</p>
            </Card>
          ) : (
            <>
              <div className="athena-paper rounded-[24px] border border-white/60 p-5 sm:p-6 shadow-[0_12px_40px_-20px_oklch(0.3_0.05_42/0.25)]">
                <div className="flex flex-wrap items-start gap-4">
                  <div className="flex-1 min-w-[220px]">
                    <div className="flex items-center gap-2 text-xs">
                      <Badge className="rounded-full capitalize bg-white text-foreground border-border">{activeTrip.status}</Badge>
                      {activeTrip.purpose && <span className="text-muted-foreground">{activeTrip.purpose}</span>}
                      <span className="hidden sm:inline-flex items-center gap-1 text-muted-foreground">· <HardDrive className="size-3" /> On device</span>
                    </div>
                    <h1 className="text-[30px] leading-none mt-2" style={serif}>{activeTrip.title}</h1>
                    <div className="flex flex-wrap items-center gap-3 mt-2 text-sm text-muted-foreground">
                      <span className="inline-flex items-center gap-1"><MapPin className="size-3.5" />{activeTrip.destination}</span>
                      {(activeTrip.startDate || activeTrip.endDate) && <span className="inline-flex items-center gap-1"><CalendarDays className="size-3.5" />{activeTrip.startDate ?? "—"} — {activeTrip.endDate ?? "—"}</span>}
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="size-[74px] rounded-2xl bg-white border border-border grid place-items-center">
                      <div className="text-center">
                        <div className="text-[22px] font-semibold leading-none" style={serif}>{progress}%</div>
                        <div className="text-[10px] font-mono uppercase tracking-widest text-muted-foreground">Packed</div>
                      </div>
                    </div>
                    <div className="hidden sm:block">
                      <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Progress</div>
                      <div className="w-28 h-1.5 rounded-full bg-black/10 mt-1 overflow-hidden"><div className="h-full bg-[oklch(0.62_0.115_38)]" style={{ width: `${progress}%` }} /></div>
                      <div className="text-xs text-muted-foreground mt-1">{items.filter(i=>i.packed).length} of {items.length} items</div>
                    </div>
                  </div>
                </div>

                <div className="flex flex-wrap gap-2 mt-4">
                  <Select value={activeTrip.status} onValueChange={(v)=>updateTripStatus({ tripId: activeTrip._id as any, status: v as any })}>
                    <SelectTrigger className="w-[160px] rounded-full bg-white"><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="planning">Planning</SelectItem>
                      <SelectItem value="packing">Packing</SelectItem>
                      <SelectItem value="ready">Ready</SelectItem>
                      <SelectItem value="archived">Archived</SelectItem>
                    </SelectContent>
                  </Select>
                  <Button variant="outline" size="sm" className="rounded-full bg-white" onClick={async()=>{ const id=await duplicateTrip({ tripId: activeTrip._id as any }); setActiveTripId(String(id)); toast.success("Trip duplicated"); }}><Copy className="size-3.5" /> Duplicate</Button>
                  <Button variant="outline" size="sm" className="rounded-full bg-white" onClick={async()=>{
                    const data = JSON.stringify({ trip: activeTrip, items, outfits }, null, 2);
                    await navigator.clipboard.writeText(data);
                    toast.success("Trip data copied");
                  }}><Share2 className="size-3.5" /> Copy data</Button>
                  <Button variant="ghost" size="sm" className="rounded-full" onClick={async()=>{ if(!confirm("Delete this trip and all its items?")) return; await deleteTrip({ tripId: activeTrip._id as any }); setActiveTripId(null); toast.success("Trip deleted"); }}><Trash2 className="size-3.5" /> Delete</Button>
                </div>
              </div>

              <Tabs defaultValue="items" className="w-full">
                <TabsList className="rounded-full bg-secondary p-1 h-auto">
                  <TabsTrigger value="items" className="rounded-full gap-1.5 data-[state=active]:bg-white"><Layers className="size-3.5" /> Packing List</TabsTrigger>
                  <TabsTrigger value="outfits" className="rounded-full gap-1.5 data-[state=active]:bg-white"><Shirt className="size-3.5" /> Outfit Planner</TabsTrigger>
                  <TabsTrigger value="share" className="rounded-full gap-1.5 data-[state=active]:bg-white"><Share2 className="size-3.5" /> Export</TabsTrigger>
                </TabsList>

                <TabsContent value="items" className="mt-4 space-y-4">
                  <Card className="rounded-2xl p-3 flex flex-wrap gap-2 items-center">
                    <div className="relative flex-1 min-w-[180px]">
                      <Search className="size-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                      <Input placeholder="Search items or categories" value={itemSearch} onChange={e=>setItemSearch(e.target.value)} className="pl-8 h-9 rounded-full" />
                    </div>
                    <Select value={filterCat} onValueChange={setFilterCat}>
                      <SelectTrigger className="w-[150px] rounded-full h-9"><SelectValue placeholder="Category" /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All categories</SelectItem>
                        {CATEGORIES.map(c=><SelectItem key={c} value={c}>{c}</SelectItem>)}
                      </SelectContent>
                    </Select>
                    <Select value={filterPacked} onValueChange={(v)=>setFilterPacked(v as any)}>
                      <SelectTrigger className="w-[140px] rounded-full h-9"><SelectValue /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All items</SelectItem>
                        <SelectItem value="packed">Packed</SelectItem>
                        <SelectItem value="unpacked">Unpacked</SelectItem>
                      </SelectContent>
                    </Select>
                    <Button variant={showEssentialOnly ? "default":"outline"} size="sm" className="rounded-full gap-1.5 h-9" onClick={()=>setShowEssentialOnly(v=>!v)}><Star className="size-3.5" /> Essentials</Button>
                    {templates.length>0 && (
                      <Select onValueChange={async(v)=>{ await applyTemplate({ templateId: v as any, tripId: activeTrip._id as any }); toast.success("Template applied"); }}>
                        <SelectTrigger className="w-[170px] rounded-full h-9"><SelectValue placeholder="Apply template" /></SelectTrigger>
                        <SelectContent>{templates.map(t=><SelectItem key={String(t._id)} value={String(t._id)}>{t.name}</SelectItem>)}</SelectContent>
                      </Select>
                    )}
                  </Card>

                  <Card className="rounded-2xl p-3">
                    <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground mb-2">Add to packing list</div>
                    <div className="grid sm:grid-cols-[1fr_140px_90px_auto] gap-2">
                      <Input placeholder="Item name — for example, Merino T-shirt" value={addRow.name} onChange={e=>setAddRow({...addRow, name:e.target.value})} />
                      <Select value={addRow.category} onValueChange={(v)=>setAddRow({...addRow, category:v})}>
                        <SelectTrigger className="rounded-full"><SelectValue /></SelectTrigger>
                        <SelectContent>{CATEGORIES.map(c=><SelectItem key={c} value={c}>{c}</SelectItem>)}</SelectContent>
                      </Select>
                      <Input type="number" min={1} value={addRow.quantity} onChange={e=>setAddRow({...addRow, quantity: Math.max(1, Number(e.target.value)||1)})} />
                      <Button className="rounded-full gap-1.5" disabled={!addRow.name.trim()} onClick={async()=>{
                        await addItem({ tripId: activeTrip._id as any, name: addRow.name, category: addRow.category, quantity: addRow.quantity, essential: addRow.essential, notes: addRow.notes || undefined });
                        setAddRow({ name:"", category:"General", quantity:1, essential:false, notes:"" });
                      }}><Plus className="size-4" />Add</Button>
                    </div>
                    <div className="flex gap-2 mt-2">
                      <Input placeholder="Notes — material, colour, or reminders" value={addRow.notes} onChange={e=>setAddRow({...addRow, notes:e.target.value})} className="h-8 text-sm" />
                      <Button variant={addRow.essential ? "default":"outline"} size="sm" className="rounded-full gap-1 h-8 shrink-0" onClick={()=>setAddRow({...addRow, essential: !addRow.essential})}><Star className="size-3.5" /> Essential</Button>
                    </div>
                  </Card>

                  {Object.keys(grouped).length===0 ? (
                    <Card className="rounded-2xl p-8 text-center border-dashed">
                      <div className="text-sm text-muted-foreground">No items match the current filters. Adjust your search or add a new item.</div>
                    </Card>
                  ) : Object.entries(grouped).map(([cat, list])=>(
                    <Card key={cat} className="rounded-2xl overflow-hidden">
                      <div className="px-4 py-3 flex items-center gap-2 bg-secondary/50">
                        <span className="text-sm font-semibold">{cat}</span>
                        <Badge variant="secondary" className="rounded-full">{list.length}</Badge>
                        <span className="ml-auto text-xs text-muted-foreground">{list.filter(i=>i.packed).length} packed</span>
                      </div>
                      <Separator />
                      <div className="divide-y">
                        {list.map(item=>(
                          <div key={String(item._id)} className={`flex items-center gap-3 px-3 sm:px-4 py-3 ${item.packed ? "bg-emerald-50/40" : "bg-white"}`}>
                            <Checkbox checked={item.packed} onCheckedChange={()=>togglePacked({ itemId: item._id as any })} />
                            <button onClick={async()=>{ const n=prompt("Edit item name", item.name); if(n && n.trim()) await updateItem({ itemId: item._id as any, name: n }); }} className="min-w-0 flex-1 text-left">
                              <div className={`text-sm leading-none truncate ${item.packed ? "line-through text-muted-foreground":"font-medium"}`}>{item.name} <span className="text-xs font-normal text-muted-foreground">×{item.quantity}</span></div>
                              {item.notes && <div className="text-xs text-muted-foreground truncate">{item.notes}</div>}
                              <div className="text-[11px] font-mono text-muted-foreground/70 mt-0.5">Tap to view detail</div>
                            </button>
                            {item.essential && <Star className="size-3.5 text-amber-500 shrink-0" />}
                            <Badge variant="outline" className="hidden sm:inline-flex rounded-full text-[11px]">{item.category}</Badge>
                            <Button variant="ghost" size="icon" className="size-7 shrink-0" onClick={async()=>{ const n=prompt("Add a photo note or detail", item.notes ?? ""); if(n!==null) await updateItem({ itemId: item._id as any, notes: n || undefined }); }}><SlidersHorizontal className="size-3.5" /></Button>
                            <Button variant="ghost" size="icon" className="size-7 shrink-0" onClick={async()=>{ await deleteItem({ itemId: item._id as any }); }}><X className="size-3.5" /></Button>
                          </div>
                        ))}
                      </div>
                    </Card>
                  ))}
                </TabsContent>

                <TabsContent value="outfits" className="mt-4 space-y-4">
                  <Card className="rounded-2xl p-4">
                    <div className="font-semibold" style={serif}>Outfit planner</div>
                    <p className="text-xs leading-5 text-muted-foreground">Select items from your list and assign a look to each day. All planning remains on device.</p>
                    <div className="grid sm:grid-cols-3 gap-2 mt-3">
                      <Input placeholder="Outfit name — for example, Arrival" value={outfitName} onChange={e=>setOutfitName(e.target.value)} />
                      <Input placeholder="Day — Monday or Day 2" value={outfitDay} onChange={e=>setOutfitDay(e.target.value)} />
                      <Button className="rounded-full" disabled={!outfitName.trim() || selectedIds.length===0} onClick={async()=>{
                        await createOutfit({ tripId: activeTrip._id as any, name: outfitName, dayLabel: outfitDay || undefined, itemIds: selectedIds as any });
                        setOutfitName(""); setOutfitDay(""); setSelectedIds([]);
                        toast.success("Outfit saved");
                      }}>Save outfit</Button>
                    </div>
                    <div className="mt-3 flex flex-wrap gap-1.5 max-h-[160px] overflow-auto">
                      {items.map(it=> {
                        const selected = selectedIds.includes(String(it._id));
                        return (
                          <button key={String(it._id)} onClick={()=> setSelectedIds(s=> s.includes(String(it._id)) ? s.filter(x=>x!==String(it._id)) : [...s, String(it._id)])}
                            className={`text-xs px-3 py-1.5 rounded-full border transition ${selected ? "bg-primary text-primary-foreground border-primary" : "bg-white hover:bg-secondary border-border"}`}>
                            {it.name}
                          </button>
                        );
                      })}
                      {items.length===0 && <span className="text-xs text-muted-foreground">Add items first, then compose outfits.</span>}
                    </div>
                    {selectedIds.length>0 && <div className="text-xs text-muted-foreground mt-2">{selectedIds.length} items selected</div>}
                  </Card>

                  <div className="grid sm:grid-cols-2 gap-3">
                    {outfits.map(o=>(
                      <Card key={String(o._id)} className="rounded-2xl p-4">
                        <div className="flex items-start gap-2">
                          <div className="flex-1">
                            <div className="font-medium leading-none" style={serif}>{o.name}</div>
                            {o.dayLabel && <div className="text-xs text-muted-foreground">{o.dayLabel}</div>}
                          </div>
                          <Button variant="ghost" size="icon" className="size-7" onClick={async()=>{ await deleteOutfit({ outfitId: o._id as any }); toast.success("Outfit removed"); }}><Trash2 className="size-3.5" /></Button>
                        </div>
                        <div className="flex flex-wrap gap-1.5 mt-3">
                          {o.itemIds.map(id=>{
                            const it = items.find(x=> String(x._id)===String(id));
                            return <span key={String(id)} className="text-xs px-2.5 py-1 rounded-full bg-secondary border border-border">{it?.name ?? "Item"}</span>;
                          })}
                        </div>
                      </Card>
                    ))}
                    {outfits.length===0 && <Card className="rounded-2xl p-8 text-center border-dashed text-sm text-muted-foreground sm:col-span-2">No outfits yet. Compose one from your packing list above.</Card>}
                  </div>
                </TabsContent>

                <TabsContent value="share" className="mt-4 space-y-4">
                  <Card className="rounded-2xl p-5">
                    <div className="font-semibold flex items-center gap-2" style={serif}><HardDrive className="size-4" /> Local data ownership</div>
                    <p className="text-xs leading-5 text-muted-foreground mt-1">PackWise keeps your trips, lists, photos, and preferences on device. Export a portable file whenever you need to move or back up your data.</p>
                    <div className="grid sm:grid-cols-3 gap-3 mt-4">
                      <Button variant="outline" className="rounded-full gap-1.5" onClick={async()=>{
                        const payload = JSON.stringify({ trip: activeTrip, items, outfits }, null, 2);
                        await navigator.clipboard.writeText(payload);
                        toast.success("Data copied to clipboard");
                      }}><Copy className="size-4" /> Copy data</Button>
                      <Button variant="outline" className="rounded-full gap-1.5" onClick={()=>{
                        const payload = JSON.stringify({ trip: activeTrip, items, outfits }, null, 2);
                        const blob = new Blob([payload], { type:"application/json" });
                        const url = URL.createObjectURL(blob);
                        const a = document.createElement("a"); a.href=url; a.download=`${activeTrip.title.replace(/\s+/g,"-")}.json`; a.click(); URL.revokeObjectURL(url);
                      }}><Download className="size-4" /> Download file</Button>
                      <label className="inline-flex items-center justify-center gap-1.5 rounded-full border border-input bg-background px-3 py-2 text-sm font-medium hover:bg-accent cursor-pointer">
                        <Upload className="size-4" /> Import file
                        <input type="file" accept="application/json" className="hidden" onChange={async(e)=>{
                          const file = e.target.files?.[0]; if(!file) return;
                          try{
                            const text = await file.text(); const data = JSON.parse(text);
                            const list = Array.isArray(data.items) ? data.items : Array.isArray(data) ? data : [];
                            for(const it of list.slice(0,60)){
                              await addItem({ tripId: activeTrip._id as any, name: String(it.name ?? "Item"), category: String(it.category ?? "General"), quantity: Number(it.quantity ?? 1), essential: Boolean(it.essential), notes: it.notes ? String(it.notes) : undefined });
                            }
                            toast.success(`Imported ${Math.min(list.length,60)} items`);
                          } catch{ toast.error("That file could not be imported"); }
                          e.target.value="";
                        }} />
                      </label>
                    </div>
                    <Separator className="my-4" />
                    <div className="text-xs leading-5 text-muted-foreground">On-device, offline-first, and private by default. No external services are required for the core experience.</div>
                    <Textarea readOnly value={JSON.stringify({ trip: activeTrip, items: items.slice(0,2), outfits: outfits.slice(0,1), note:"Preview · Use Copy or Download for the complete file" }, null, 2)} className="mt-3 font-mono text-xs h-[150px] bg-secondary/40" />
                  </Card>
                </TabsContent>
              </Tabs>
            </>
          )}
        </main>
      </div>
    </div>
  );
}
