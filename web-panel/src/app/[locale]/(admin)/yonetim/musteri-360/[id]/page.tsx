import Musteri360DetayManager from "@/components/yonetim/panel/Musteri360DetayManager";

export const metadata = { title: "Müşteri 360°" };

export default async function Musteri360DetayPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return <Musteri360DetayManager householdId={id} />;
}
