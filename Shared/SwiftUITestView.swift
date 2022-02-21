//
//  SwiftUITestView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 20/02/22.
//

import SwiftUI

struct SwiftUITestView: View {
    @Namespace private var namespace
    @State private var showDetail = true

    @State private var rotate = false

    var body: some View {
        if(showDetail == false) {
            ZStack {
                
                Color.green
                    .matchedGeometryEffect(id: "title", in: namespace)
                    .frame(width: 500, height: 500, alignment: .leading)
                    .rotationEffect(.degrees(rotate ? 360 : 0))

//                Text("Test1")
//                    .matchedGeometryEffect(id: "title", in: namespace)
//                    .frame(width: 500, height: 500, alignment: .center)
//                    .rotationEffect(.degrees(rotate ? 180 : 0))
//                    .background(
//                        Color.red
//                    )
//                    .animation(.easeInOut(duration: 3).delay(3), value: rotate)
            }.onTapGesture {
                withAnimation {
                    showDetail.toggle()
                }
            }.onAppear {
                withAnimation(Animation.linear(duration: 0.3)) {
                        self.rotate.toggle()
                    }
                    
//                    withAnimation(Animation.linear(duration: 8.0).repeatForever(autoreverses: false)) {
//                        self.rotate = true
//                    }
            }
        } else {
            VStack {
                Spacer()
                HStack {
                    Color.red
                        .frame(width: 100, height: 100)
                    Color.orange
                        .frame(width: 100, height: 100)
                    Color.purple
                        .frame(width: 100, height: 100)
                    Button(action: { print("") }) {
                                       Text("item")
                                           .contentShape(Rectangle())
                                           .aspectRatio(1, contentMode: .fill)
                                           .frame(width: 100, height: 100)
                                           .background(
                                            Color.gray                    .matchedGeometryEffect(id: "title", in: namespace)

                                                
                                           )
                    }
                }
               
//                Text("Test2")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text("Test3")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text("Test4")
//                    .matchedGeometryEffect(id: "title", in: namespace)
//                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onTapGesture {
                withAnimation {
                    showDetail.toggle()
                    rotate = true
                }
            }
        }
     
        
//        if showDetail {
//                ZStack {
//                    Button("Test1") {
//                        showDetail = false
//                    }
//                    .frame(width: 100, height: 100)
//                    .background(
//                        Color.green
//                            .matchedGeometryEffect(id: "color", in: namespace)
//                    )
//                    .matchedGeometryEffect(id: "id", in: namespace)
//
////                    Color.red
////                        .frame(width: 200, height: 200)
////                        .onTapGesture {
////                            showDetail = false
////                        }
////                        .matchedGeometryEffect(id: "id", in: namespace)
//                }
//
//        } else {
//
//            ZStack {
//                Button("Test2") {
//                    showDetail = true
//                }
//                .frame(width: 600, height: 600)
//                .background(
//                    Color.red
//                        .matchedGeometryEffect(id: "color", in: namespace)
//                )
//                .matchedGeometryEffect(id: "id", in: namespace)
//            }
//        }
    
//            VStack {
//                HStack {
//    //                HikeGraph(data: hike, path: \.elevation)
//    //                    .frame(width: 50, height: 30)
//
//                    VStack(alignment: .leading) {
//                        Text("title")
//                            .font(.headline)
//                        Text("Detail")
//                    }
//
//                    Spacer()
//
//                    Button {
//                        withAnimation {
//                            showDetail.toggle()
//                        }
//                    } label: {
//                        Label("Graph", systemImage: "chevron.right.circle")
//                            .labelStyle(.iconOnly)
//                            .imageScale(.large)
//                            .rotationEffect(.degrees(showDetail ? 90 : 0))
//                            .scaleEffect(showDetail ? 1.5 : 1)
//                            .padding()
//                    }
//                }
//
//
//                Color.red
//                    .frame(width: 100, height: 100)
//                    .matchedGeometryEffect(id: "id", in: namespace)
//
//
////                    .rotationEffect(.degrees(showDetail ? 360 : 0))
////                    .transition(.scale)
//
//
//    //            if showDetail {
//    //                Color.red
//    //                    .frame(width: 100, height: <#T##CGFloat?#>, alignment: <#T##Alignment#>)
//    //                    .transition(.scale)
//    ////                HikeDetail(hike: hike)
//    ////                    .transition(.slide)
//    //            }
//            }
//        }
    }
}

struct SwiftUITestView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUITestView()
    }
}


//        ZStack {
//            if (showDetail) {
//                Text("Test1")
//                    .matchedGeometryEffect(id: "title", in: namespace)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            } else {
//                Text("Test2")
//                    .matchedGeometryEffect(id: "title", in: namespace)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//            }
//
//        }.onTapGesture {
//            withAnimation {
//                showDetail.toggle()
//            }
//        }
