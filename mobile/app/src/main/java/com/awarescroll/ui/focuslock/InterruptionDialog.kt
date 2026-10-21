package com.awarescroll.ui.focuslock

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.awarescroll.ui.theme.*

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun InterruptionDialog(
    onConfirmExit: (reasonCategory: String, reasonText: String) -> Unit,
    onDismiss: () -> Unit
) {
    var selectedCategory by remember { mutableStateOf("Boredom") }
    var reasonText by remember { mutableStateOf("") }

    val categories = listOf("Boredom", "Notification", "External", "Fatigue", "Other")

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(text = "Log Interruption", style = H2, color = MaterialTheme.colorScheme.error)
        },
        text = {
            Column(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Understanding why focus breaks turns drift into actionable data for next time.",
                    style = BodySmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )

                Spacer(modifier = Modifier.height(16.dp))
                Text(text = "Primary Trigger", style = H3)
                Spacer(modifier = Modifier.height(8.dp))

                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    categories.forEach { cat ->
                        FilterChip(
                            selected = selectedCategory == cat,
                            onClick = { selectedCategory = cat },
                            label = { Text(cat) }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))
                OutlinedTextField(
                    value = reasonText,
                    onValueChange = { reasonText = it },
                    label = { Text("What happened? (e.g. check notification)") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp)
                )
            }
        },
        confirmButton = {
            DestructiveButton(
                text = "CONFIRM EARLY EXIT",
                onClick = {
                    val finalReason = if (reasonText.isNotBlank()) reasonText else selectedCategory
                    onConfirmExit(selectedCategory.lowercase(), finalReason)
                }
            )
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("RESUME FOCUS", color = Primary)
            }
        },
        containerColor = MaterialTheme.colorScheme.surface
    )
}
