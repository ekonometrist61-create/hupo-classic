import PotansiyelAdayDetayManager from "@/components/yonetim/panel/PotansiyelAdayDetayManager";

export default async function PotansiyelAdayDetayPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return <PotansiyelAdayDetayManager prospectId={id} />;
}
