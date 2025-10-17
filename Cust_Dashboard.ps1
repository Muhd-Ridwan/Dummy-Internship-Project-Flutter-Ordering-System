import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustDashboard extends StatefulWidget {
  const CustDashboard({super.key});

  @override
  State<CustDashboard> createState() => _CustDashboardState();
}

class _CustDashboardState extends State<CustDashboard> {
  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Customer Dashboard',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: Icon(Icons.logout),
              onPressed: (){},
            ),
          ],
        ),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints){
              final w = constraints.maxWidth;

              // SET RESPONSIVENESS
              int cols;
              double maxW;
              if(w >= 1200){
                // DESKTOP SIZE
                cols = 3;
                maxW = 1000;
              } else if (w >= 800){
                // LARGE TABLET
                cols = 3;
                maxW = 900;
              } else if (w >= 600){
                // TABLET SIZE
                cols = 2;
                maxW = 650;
              } else {
                // PHONE SIZE
                cols = 1;
                maxW = 420;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    children: [
                      _DashBoardCard(
                        icon: Icons.receipt_long,
                        title: 'Order History',
                        subtitle: 'See your past orders',
                      ),
                      _DashBoardCard(
                        icon: Icons.storefront,
                        title: 'Browse Products',
                        subtitle: 'Explore our product catalog',
                      ),
                      _DashBoardCard(
                        icon: Icons.person,
                        title: 'Profile',
                        subtitle: 'View and edit your profile',
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}


// CARD FOR CUSTOMER DASHBOARD
class _DashBoardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

// THIS IS HOW TO MAKE A CARD AND PASS THE DATA FROM MAIN TO THE CARD CLASS
  const _DashBoardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      child: InkWell(
        onTap: (){},
        hoverColor: isDark ? Colors.white10 : Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 46),
              const SizedBox(height: 14,),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}