package com.google.android.mms.pdu;
import java.util.ArrayList; import java.util.List;
public class PduBody { private final List<PduPart> parts = new ArrayList<PduPart>(); public void addPart(PduPart p){parts.add(p);} public int getPartsNum(){return parts.size();} public PduPart getPart(int i){return parts.get(i);} }
